import subprocess, atexit, os, signal, threading, time
import cv2, numpy as np
from flask import Flask, Response, send_from_directory , render_template
from flask_cors import CORS
from flask_socketio import SocketIO
import shutil, platform
import math

# python-can 패키지 임포트 (없으면 None으로 설정)
try:
    import can
except ImportError:
    can = None


# ====== 카메라 관련 기본 설정 ======
width, height = 640 , 480          # 영상 해상도
fps = 30                          # 프레임 속도
frame_size = width * height * 3 // 2  # YUV420 한 프레임 크기

# 전역 변수
rpicam = None   # Raspberry Pi 카메라 프로세스 핸들
cap = None      # OpenCV VideoCapture 객체

# Flask 서버 초기화 (정적 파일: static 폴더)
app = Flask(__name__, static_folder="static")

# CORS 허용 (다른 도메인에서 요청 가능)
CORS(app, supports_credentials=True)

# SocketIO 서버 초기화 (eventlet 비동기 모드 사용)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="eventlet")


# ====== 최신 차량 상태 데이터 (텔레메트리) ======
telemetry = {
    "rpm": 0,          # 엔진 RPM
    "speed": 0,    # 속도 (cm/s)
    "gear": 0,         # 기어 상태 (0:N,1:D,2:R,3:P)
    "battery": 0       # 배터리 잔량 (%)
}


# rpicam-vid 
def has_rpicam():
    # 조건, rpicam-vid 명령어 존재 여부 + ARM CPU 확인
    return shutil.which("rpicam-vid") is not None and platform.machine().startswith(("arm", "aarch64"))


def start_camera():
    global rpicam, cap
    if has_rpicam():
        # Raspberry Pi 카메라 사용
        if rpicam is None or rpicam.poll() is not None:
            rpicam = subprocess.Popen([
                'rpicam-vid',
                '--inline',
                '--flush',
                '--width', str(width),
                '--height', str(height),
                '--framerate', str(fps),
                '--codec', 'yuv420',  # YUV420 포맷
                '--timeout', '0',     # 무한 실행
                '--nopreview',        # 미리보기 비활성화
                '-o', '-'             # 표준출력으로 전송
            ], stdout=subprocess.PIPE, preexec_fn=os.setsid)
            atexit.register(stop_camera)  # 프로그램 종료 시 카메라 정리
    else:
        # 일반 PC/Mac 웹캠 사용
        if cap is None:
            backend = cv2.CAP_AVFOUNDATION if platform.system() == "Darwin" else cv2.CAP_ANY
            cap = cv2.VideoCapture(0, backend)
            cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
            cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
            cap.set(cv2.CAP_PROP_FPS, fps)
            if not cap.isOpened():
                raise RuntimeError("cannot open webcam")

def stop_camera():
    global rpicam, cap
    # Pi 카메라 프로세스 종료 --> 카메라 프로세스가 좀비프로세스로 남는 상황이 생길 수도 있음 
    if rpicam and rpicam.poll() is None:
        try:
            os.killpg(rpicam.pid, signal.SIGTERM)
            rpicam.wait(timeout=2)
        except Exception:
            pass
        try:
            rpicam.wait(timeout=2)
        except Exception:
            pass
    rpicam = None

    # OpenCV 캡처 종료
    if cap is not None:
        try:
            cap.release()
        except Exception:
            pass
    cap = None


# ====== 프레임 생성 제너레이터 ======
def frame_generator():
    start_camera()
    # Raspberry Pi 카메라 사용 시
    if rpicam and rpicam.poll() is None:
        while True:
            # YUV420 포맷의 한 프레임 읽기
            raw = rpicam.stdout.read(frame_size)
            if not raw or len(raw) < frame_size:
                continue
            # NumPy 배열 변환 및 BGR로 변환
            yuv = np.frombuffer(raw, dtype=np.uint8).reshape((height * 3 // 2, width))
            bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
            bgr = cv2.rotate(bgr, cv2.ROTATE_180)  # Pi 카메라 180도 회전
            ok, jpeg = cv2.imencode('.jpg', bgr, [int(cv2.IMWRITE_JPEG_QUALITY), 80])
            if not ok:
                print("CV JPEG incoding error ")
                continue
            # MJPEG 스트리밍 포맷으로 전송
            yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' + jpeg.tobytes() + b'\r\n')
    else:
        # PC/Mac 웹캠 사용 시
        while True:
            ok, bgr = cap.read()
            if not ok:
                break

            ok, jpeg = cv2.imencode('.jpg', bgr, [int(cv2.IMWRITE_JPEG_QUALITY), 80])
            if not ok:
                continue
            yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' + jpeg.tobytes() + b'\r\n')


# ====== 카메라 스트리밍 엔드포인트 : /video_feed ======
@app.route('/video_feed')
def video_feed():
    return Response(frame_generator(), mimetype='multipart/x-mixed-replace; boundary=frame')


# dist파일 라우팅 
@app.route('/')
def index():
    # static 폴더의 index.html 반환
    return send_from_directory(app.static_folder, 'index.html')

@app.route("/assets/<path:filename>")
def assets(filename):
    # static/assets 하위 파일 서빙
    return send_from_directory(f"{app.static_folder}/assets", filename)


# ====== 텔레메트리 송신 루프 ======
def telemetry_loop():
    if can is None:
        pass
    else:
        bus = can.interface.Bus(channel='can0', interface='socketcan')
        last_emit = 0
        while True:
            msg = bus.recv(timeout=0.05)
            if msg:
                # RPM + 속도
                if msg.arbitration_id == 0x100 and msg.dlc >= 2:
                    rpm = (msg.data[0] << 8) | msg.data[1]
                    telemetry["rpm"] = int(rpm)
                    wheel_diam_cm = 6.8
                    cm_per_sec = (rpm / 60.0) * (math.pi * wheel_diam_cm)
                    telemetry["speed"] = int(round(cm_per_sec))

                # 기어
                elif msg.arbitration_id == 0x101 and msg.dlc >= 1:
                    gear_val = int(msg.data[0])
                    telemetry["gear"] = {0:"N", 1:"D", 2:"R", 3:"P"}.get(gear_val, "?")

                # 배터리 (CAN ID 0x102)
                elif msg.arbitration_id == 0x102 and msg.dlc >= 1:
                    telemetry["battery"] = int(msg.data[0])

            # 주기적으로 브라우저에 전송
            now = time.time()
            if now - last_emit >= 0.1:
                socketio.emit('telemetry', telemetry)
                last_emit = now
            socketio.sleep(0.01)


# ====== 메인 함수 ======
def main():
    print("Server on: http://0.0.0.0:8080")
    start_camera()  # 카메라 초기화
    socketio.start_background_task(telemetry_loop)  # 텔레메트리 송신 쓰레드 시작
    socketio.run(app, host='0.0.0.0', port=8080)    # Flask+SocketIO 서버 실행


# 프로그램 시작점
if __name__ == '__main__':
    main()
