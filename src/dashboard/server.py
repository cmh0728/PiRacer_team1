# server.py
import os, time, math, signal, atexit, platform, shutil, subprocess, threading
import cv2, numpy as np
from flask import Flask, Response, request , jsonify
from flask_cors import CORS
from flask_socketio import SocketIO
import asyncio
from fractions import Fraction

import psutil, socket  # for cpu usages

# ---- eventlet ----
# asyncio(aiortc)와 충돌 방지를 위해 socket 패치는 끈다.
import eventlet
eventlet.monkey_patch(socket=False)

# --- WebRTC (UDP) 추가 임포트 ---
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
FPS = 30
ROTATE_180 = True              # 필요 시 카메라 180도 회전
JPEG_QUALITY = 80
TARGET_MJPEG_FPS = 15          # 브라우저로 내보낼 최대 FPS (WebRTC도 이 값 기준)
IDLE_STOP_SEC = 5.0            # 시청자 0명 지속 시 캡처 종료 지연

FRAME_SIZE = WIDTH * HEIGHT * 3 // 2  # YUV420(I420) 한 프레임 바이트 수

# SIGPIPE 무시 (브라우저가 탭 닫아도 프로세스 죽지 않게)
try:
    signal.signal(signal.SIGPIPE, signal.SIG_IGN)
except Exception:
    pass

# Flask / SocketIO
# 정적 파일은 React 빌드 산출물을 static/에 넣고, index.html도 그 안에 둔다(간단한 방식).
app = Flask(__name__, static_folder="static", static_url_path="/")
CORS(app, supports_credentials=True)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="eventlet")  # pip install eventlet

# ================== 전역 상태 ==================
rpicam = None              # rpicam-vid 프로세스 핸들
cap = None                 # OpenCV VideoCapture 핸들(PC 테스트용)
capture_thread = None
capture_running = False
latest_jpeg = None         # 최신 JPEG 바이트
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

class CameraTrack(MediaStreamTrack):
    kind = "video"
    def __init__(self):
        super().__init__()
        self._ts = 0
        self._time_base = Fraction(1, max(1, TARGET_MJPEG_FPS))

    async def recv(self):
        # 타이밍 (프레임 레이트)
        await asyncio.sleep(1 / max(1, TARGET_MJPEG_FPS))

        # 최신 JPEG → ndarray
        with frame_lock:
            buf = latest_jpeg

        if not buf:
            img = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)
        else:
            img = cv2.imdecode(np.frombuffer(buf, np.uint8), cv2.IMREAD_COLOR)
            if img is None:
                img = np.zeros((HEIGHT, WIDTH, 3), dtype=np.uint8)

        frame = VideoFrame.from_ndarray(img, format="bgr24")
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
            # 🔹 끊길 때 viewer 감소 + idle stop 트리거
            _remove_viewer()

    await pc.setRemoteDescription(RTCSessionDescription(sdp=offer_sdp, type=offer_type))
    pc.addTrack(CameraTrack())
    answer = await pc.createAnswer()
    await pc.setLocalDescription(answer)
    return pc.localDescription

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

def encode_and_store(bgr: np.ndarray):
    """BGR → JPEG 인코딩 후 전역 최신 프레임으로 저장"""
    global latest_jpeg, latest_ts
    ok, jpeg = cv2.imencode('.jpg', bgr, [int(cv2.IMWRITE_JPEG_QUALITY), JPEG_QUALITY])
    if not ok:
        return
    with frame_lock:
        latest_jpeg = jpeg.tobytes()
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
                encode_and_store(bgr)
            elif cap is not None:
                ok, bgr = cap.read()
                if not ok:
                    time.sleep(0.01)
                    continue
                encode_and_store(bgr)
            else:
                time.sleep(0.05)
        except Exception:
            # 예외 시 잠깐 쉬고 재시작
            time.sleep(0.05)

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

# --- viewer 카운트 헬퍼 (active_viewers와 idle stop 재사용) ---
def _add_viewer():
    global active_viewers
    with av_lock:
        active_viewers += 1

def _remove_viewer():
    global active_viewers
    with av_lock:
        active_viewers = max(0, active_viewers - 1)
    stop_capture_if_idle()

# ================== 라우트 ==================
@app.route("/")
def index():
    # static/index.html을 React 엔트리로 사용
    return app.send_static_file("index.html")

@app.route("/health")
def health():
    return {"ok": True, "viewers": active_viewers, "ts": latest_ts}, 200

@app.route("/video_feed")
def video_feed():
    """모든 클라이언트에게 최신 JPEG 프레임을 브로드캐스트(MJPEG)"""
    global active_viewers
    # 시청자 수 증가 + 캡처 보장
    with av_lock:
        active_viewers += 1
    start_capture_if_needed()

    def gen():
        last_ts_local = 0.0
        per_frame_delay = 1.0 / max(1, TARGET_MJPEG_FPS)
        try:
            while True:
                # 최신 프레임 대기/획득
                with frame_lock:
                    buf = latest_jpeg
                    ts = latest_ts
                if not buf:
                    time.sleep(0.01)
                    continue
                if ts <= last_ts_local:
                    time.sleep(0.005)
                    continue
                # 전송
                chunk = (b"--frame\r\n"
                         b"Content-Type: image/jpeg\r\n\r\n" +
                         buf + b"\r\n")
                yield chunk
                last_ts_local = ts
                # 전송 레이트 제한(과도한 전송 방지)
                time.sleep(per_frame_delay)
        except (BrokenPipeError, ConnectionResetError, GeneratorExit, IOError):
            # 클라이언트 이탈(정상)
            pass
        finally:
            # 시청자 수 감소 + 필요 시 캡처 중단 예약
            with av_lock:
                active_viewers = max(0, active_viewers - 1)
            stop_capture_if_idle()

    headers = {
        "Cache-Control": "no-cache, private",
        "Pragma": "no-cache",
        "Connection": "keep-alive",
    }
    return Response(gen(), mimetype="multipart/x-mixed-replace; boundary=frame", headers=headers)

# ---- WebRTC 시그널링 (브라우저 → 서버) ----
@app.route("/rtc/offer", methods=["POST"])
def rtc_offer():
    if not AIORTC_OK:
        return jsonify({"error": "aiortc not installed"}), 500

    data = request.get_json(force=True)
    offer_sdp = data.get("sdp")
    offer_type = data.get("type", "offer")
    if not offer_sdp:
        return jsonify({"error": "missing sdp"}), 400

    # WebRTC만 들어와도 캡처가 켜지도록
    start_capture_if_needed()
    _add_viewer()

    fut = _run_coro(_handle_offer(offer_sdp, offer_type))
    try:
        desc = fut.result(timeout=5)
    except Exception as e:
        # 실패 시 viewer 롤백
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
        # 데모/유휴 모드: 너무 시끄럽지 않게 그대로 유지 or 간단 샘플
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
