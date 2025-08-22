# server.py  (UDP/WebRTC only, low-latency tuned)
import os, time, math, signal, atexit, platform, shutil, subprocess, threading
import cv2, numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_socketio import SocketIO
import asyncio
from fractions import Fraction

import psutil, socket  # for cpu usages

# ---- eventlet ----
# aiortc(asyncio)와 충돌 방지를 위해 socket 패치는 끈다.
import eventlet
eventlet.monkey_patch(socket=False)

# --- WebRTC (UDP) ---
try:
    from aiortc import RTCPeerConnection, RTCSessionDescription, MediaStreamTrack
    from av import VideoFrame
    AIORTC_OK = True
except Exception:
    AIORTC_OK = False

# =====(선택) python-can 임포트 =====
try:
    import can
except ImportError:
    can = None

# ================== 설정 ==================
WIDTH, HEIGHT = 640, 480
FPS = 30                   # 실제 캡처 FPS
ROTATE_180 = True          # 필요 시 카메라 180도 회전
IDLE_STOP_SEC = 5.0        # 시청자 0명 지속 시 캡처 종료 지연

FRAME_SIZE = WIDTH * HEIGHT * 3 // 2  # YUV420(I420) 한 프레임 바이트 수

# SIGPIPE 무시 (브라우저가 탭 닫아도 프로세스 죽지 않게)
try:
    signal.signal(signal.SIGPIPE, signal.SIG_IGN)
except Exception:
    pass

# Flask / SocketIO
app = Flask(__name__, static_folder="static", static_url_path="/")
CORS(app, supports_credentials=True)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="eventlet")

# ================== 전역 상태 ==================
rpicam = None              # rpicam-vid 프로세스 핸들
cap = None                 # OpenCV VideoCapture 핸들(PC 테스트용)
capture_thread = None
capture_running = False

latest_bgr = None          # 최신 프레임 (BGR ndarray)
latest_ts = 0.0            # 최신 프레임 타임스탬프

active_viewers = 0         # 현재 시청자 수
av_lock = threading.Lock()
frame_lock = threading.Lock()
idle_timer = None
idle_lock = threading.Lock()

# --- WebRTC용 asyncio 루프/PC 관리 ---
asyncio_loop = None
pcs = set()

def _start_asyncio_loop():
    global asyncio_loop
    asyncio_loop = asyncio.new_event_loop()
    asyncio.set_event_loop(asyncio_loop)
    asyncio_loop.run_forever()

def _run_coro(coro):
    # 다른 스레드에서 asyncio 코루틴 실행
    return asyncio.run_coroutine_threadsafe(coro, asyncio_loop)

# ================== 유틸/카메라 ==================
def has_rpicam() -> bool:
    """Pi + rpicam-vid 사용 가능 여부"""
    return shutil.which("rpicam-vid") is not None and platform.machine().startswith(("arm", "aarch64"))

def start_camera_process():
    """필요 시 rpicam-vid 또는 OpenCV 캡처 시작"""
    global rpicam, cap
    if has_rpicam():
        if rpicam is None or rpicam.poll() is not None:
            rpicam = subprocess.Popen(
                [
                    'rpicam-vid',
                    '--inline', '--flush',
                    '--width', str(WIDTH),
                    '--height', str(HEIGHT),
                    '--framerate', str(FPS),
                    '--codec', 'yuv420',   # YUV420(I420) raw
                    '--timeout', '0',
                    '--nopreview',
                    '-o', '-',             # stdout
                ],
                stdout=subprocess.PIPE,
                bufsize=0,
                preexec_fn=os.setsid
            )
            atexit.register(stop_camera_process)
    else:
        if cap is None:
            backend = cv2.CAP_AVFOUNDATION if platform.system() == "Darwin" else cv2.CAP_ANY
            cap = cv2.VideoCapture(0, backend)
            cap.set(cv2.CAP_PROP_FRAME_WIDTH, WIDTH)
            cap.set(cv2.CAP_PROP_FRAME_HEIGHT, HEIGHT)
            cap.set(cv2.CAP_PROP_FPS, FPS)
            if not cap.isOpened():
                raise RuntimeError("cannot open webcam")

def stop_camera_process():
    """카메라 종료"""
    global rpicam, cap
    # rpicam-vid 종료
    if rpicam and rpicam.poll() is None:
        try:
            os.killpg(rpicam.pid, signal.SIGTERM)
        except Exception:
            pass
        try:
            rpicam.wait(timeout=2)
        except Exception:
            pass
    rpicam = None
    # OpenCV 종료
    if cap is not None:
        try:
            cap.release()
        except Exception:
            pass
    cap = None

def read_exact(n: int) -> bytes:
    """rpicam stdout에서 정확히 n바이트 읽기 (부분 읽기 보완)"""
    assert rpicam and rpicam.stdout
    buf = bytearray()
    while len(buf) < n:
        chunk = rpicam.stdout.read(n - len(buf))
        if not chunk:
            break
        buf.extend(chunk)
    return bytes(buf)

def store_frame(bgr: np.ndarray):
    """최신 BGR 프레임 저장 (JPEG 인코딩 없이)"""
    global latest_bgr, latest_ts
    with frame_lock:
        latest_bgr = bgr.copy()
        latest_ts = time.time()

def capture_loop():
    """단일 캡처 루프(모든 클라이언트가 공유)"""
    global capture_running
    backoff = 0.2
    while capture_running:
        try:
            start_camera_process()
            if rpicam and rpicam.poll() is None:
                raw = read_exact(FRAME_SIZE)
                if not raw or len(raw) < FRAME_SIZE:
                    # 파이프 끊김 → 재시작
                    stop_camera_process()
                    time.sleep(backoff)
                    backoff = min(2.0, backoff * 1.5)
                    continue
                backoff = 0.2
                yuv = np.frombuffer(raw, dtype=np.uint8).reshape((HEIGHT * 3 // 2, WIDTH))
                bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
                if ROTATE_180:
                    bgr = cv2.rotate(bgr, cv2.ROTATE_180)
                store_frame(bgr)
            elif cap is not None:
                ok, bgr = cap.read()
                if not ok:
                    time.sleep(0.001)
                    continue
                if ROTATE_180:
                    bgr = cv2.rotate(bgr, cv2.ROTATE_180)
                store_frame(bgr)
            else:
                time.sleep(0.01)
        except Exception:
            # 예외 시 잠깐 쉬고 재시작
            time.sleep(0.01)

def start_capture_if_needed():
    """첫 시청자 유입 시 캡처 시작"""
    global capture_running, capture_thread
    if not capture_running:
        capture_running = True
        capture_thread = threading.Thread(target=capture_loop, name="capture_loop", daemon=True)
        capture_thread.start()

def _idle_stop_if_still_zero():
    """IDLE_STOP_SEC 후에도 시청자 0명이면 캡처 중단"""
    global capture_running, capture_thread
    with av_lock:
        if active_viewers > 0:
            return
    capture_running = False
    stop_camera_process()
    if capture_thread and capture_thread.is_alive():
        capture_thread.join(timeout=1.0)

def stop_capture_if_idle():
    """시청자 0명일 때 지연 후 캡처 중단(플러터/새로고침 대비)"""
    global idle_timer
    with av_lock:
        if active_viewers > 0:
            return
    with idle_lock:
        if idle_timer and idle_timer.is_alive():
            return
        idle_timer = threading.Timer(IDLE_STOP_SEC, _idle_stop_if_still_zero)
        idle_timer.daemon = True
        idle_timer.start()

# --- viewer 카운트 헬퍼 ---
def _add_viewer():
    global active_viewers
    with av_lock:
        active_viewers += 1

def _remove_viewer():
    global active_viewers
    with av_lock:
        active_viewers = max(0, active_viewers - 1)
    stop_capture_if_idle()

# ================== Web ==================
@app.route("/")
def index():
    # static/index.html을 React 엔트리로 사용
    return app.send_static_file("index.html")

@app.route("/health")
def health():
    return {"ok": True, "viewers": active_viewers, "ts": latest_ts}, 200

# ================== (TCP MJPEG 경로 제거/비활성) ==================
# UDP만 사용하므로 /video_feed 라우트는 제공하지 않음.
# 필요하면 과거 MJPEG 라우트를 복구하세요.

# ---- WebRTC 시그널링 (브라우저 → 서버, UDP) ----
class CameraTrack(MediaStreamTrack):
    """JPEG 재인코딩 없이 최신 BGR 프레임을 즉시 내보내 저지연화"""
    kind = "video"
    def __init__(self):
        super().__init__()
        self._ts = 0
        self._last_ts = 0.0
        self._time_base = Fraction(1, max(1, FPS))  # 송출 타임베이스

    async def recv(self):
        # 새 프레임 대기: 1ms 단위로 최대 ~1초 기다림 (큐 방지)
        bgr = None
        for _ in range(1000):
            with frame_lock:
                ts = latest_ts
                if latest_bgr is not None:
                    bgr = latest_bgr.copy()
                else:
                    bgr = None
            if bgr is not None and ts != self._last_ts:
                self._last_ts = ts
                break
            await asyncio.sleep(0.001)  # 1ms 폴링

        if bgr is None:
            bgr = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)

        frame = VideoFrame.from_ndarray(bgr, format="bgr24")
        self._ts += 1
        frame.pts = self._ts
        frame.time_base = self._time_base
        return frame

async def _handle_offer(offer_sdp: str, offer_type: str):
    pc = RTCPeerConnection()
    pcs.add(pc)

    @pc.on("connectionstatechange")
    async def _on_state_change():
        if pc.connectionState in ("failed", "closed", "disconnected"):
            await pc.close()
            pcs.discard(pc)
            _remove_viewer()

    await pc.setRemoteDescription(RTCSessionDescription(sdp=offer_sdp, type=offer_type))

    # 트랙 추가
    track = CameraTrack()
    sender = pc.addTrack(track)

    # 🔻 인코더 큐 방지: 비트레이트/프레임레이트 상한
    try:
        params = sender.getParameters()
        encs = params.encodings or [{}]
        encs[0].update({"maxBitrate": 1_200_000, "maxFramerate": FPS})  # 1.2Mbps @ 30fps
        params.encodings = encs
        await sender.setParameters(params)
    except Exception:
        # 일부 환경에서 setParameters 미지원일 수 있음 → 무시
        pass

    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)
    return pc.localDescription

@app.route("/rtc/offer", methods=["POST"])
def rtc_offer():
    if not AIORTC_OK:
        return jsonify({"error": "aiortc not installed"}), 500

    data = request.get_json(force=True)
    offer_sdp = data.get("sdp")
    offer_type = data.get("type", "offer")
    if not offer_sdp:
        return jsonify({"error": "missing sdp"}), 400

    # WebRTC만 접속해도 캡처 시작
    start_capture_if_needed()
    _add_viewer()

    fut = _run_coro(_handle_offer(offer_sdp, offer_type))
    try:
        desc = fut.result(timeout=5)
    except Exception as e:
        _remove_viewer()
        return jsonify({"error": str(e)}), 500

    return jsonify({"sdp": desc.sdp, "type": desc.type})

# ================== 텔레메트리(Socket.IO) ==================
telemetry = {
    "rpm": 0,
    "speed": 0,      # cm/s
    "gear": 0,       # 0:N,1:D,2:R,3:P
    "battery": 0,    # %
}

def check_network(host="8.8.8.8", port=53, timeout=1):
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        return True
    except Exception:
        return False

def telemetry_loop():
    """python-can 있으면 실제 CAN 읽기, 없으면 no-op/샘플"""
    if can is None:
        while True:
            telemetry["cpu"] = psutil.cpu_percent()
            telemetry["net"] = check_network()
            socketio.emit("telemetry", telemetry)
            socketio.sleep(0.2)
    else:
        bus = can.interface.Bus(channel="can0", interface="socketcan")
        last_emit = 0.0
        while True:
            msg = bus.recv(timeout=0.05)
            if msg:
                if msg.arbitration_id == 0x100 and msg.dlc >= 2:
                    rpm = (msg.data[0] << 8) | msg.data[1]
                    telemetry["rpm"] = int(rpm)
                    wheel_diam_cm = 6.8
                    cm_per_sec = (rpm / 60.0) * (math.pi * wheel_diam_cm)
                    telemetry["speed"] = int(round(cm_per_sec))
                elif msg.arbitration_id == 0x101 and msg.dlc >= 1:
                    gear_val = int(msg.data[0])
                    if gear_val == 0:
                        telemetry["gear"] = "N"
                    elif gear_val == 1:
                        telemetry["gear"] = "D"
                    elif gear_val == 2:
                        telemetry["gear"] = "R"
                    elif gear_val == 3:
                        telemetry["gear"] = "P"
                elif msg.arbitration_id == 0x102 and msg.dlc >= 1:
                    telemetry["battery"] = int(msg.data[0])

            now = time.time()
            if now - last_emit >= 0.1:
                telemetry["cpu"] = psutil.cpu_percent()
                telemetry["net"] = check_network()
                socketio.emit("telemetry", telemetry)
                last_emit = now
            socketio.sleep(0.01)

@app.route("/api/reset", methods=["POST"])
def reset():
    data = request.get_json()
    password = data.get("password")
    try:
        proc = subprocess.run(
            ["sudo", "-S", "reboot"],
            input=password + "\n",
            text=True,
            capture_output=True
        )
        if proc.returncode == 0:
            return jsonify({"ok": True}), 200
        else:
            return jsonify({"ok": False, "error": proc.stderr}), 401
    except Exception as e:
        return jsonify({"ok": False, "error": str(e)}), 500

# ================== 엔트리포인트 ==================
def main():
    print("Server on: http://0.0.0.0:8080")
    # WebRTC용 asyncio 루프 스레드 시작
    threading.Thread(target=_start_asyncio_loop, daemon=True).start()
    # 텔레메트리 백그라운드 태스크
    socketio.start_background_task(telemetry_loop)
    # Flask+SocketIO 실행
    socketio.run(app, host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()
