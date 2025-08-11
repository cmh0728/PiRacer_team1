# server.py  (라즈베리파이에서 실행)
import subprocess, atexit, os, signal, threading, time
import cv2, numpy as np
from flask import Flask, Response, send_from_directory
from flask_cors import CORS
from flask_socketio import SocketIO
# pip install python-can (필요 시)
try:
    import can
except ImportError:
    can = None

width, height = 640, 480
frame_size = width * height * 3 // 2

rpicam = None
app = Flask(__name__, static_folder="static")  # /static/index.html 서빙
CORS(app, supports_credentials=True)
socketio = SocketIO(app, cors_allowed_origins="*", async_mode="eventlet")  # pip install eventlet

# 최신 텔레메트리 스냅샷
telemetry = {
    "rpm": 0,
    "speed_cms": 0,
    "gear": 0,           # 0:N,1:D,2:R,3:P
    "battery": 0         # %
}

def start_camera():
    global rpicam
    if rpicam is None or rpicam.poll() is not None:
        rpicam = subprocess.Popen([
            'rpicam-vid',
            '--width', str(width),
            '--height', str(height),
            '--framerate', '30',
            '--codec', 'yuv420',
            '--timeout', '0',
            '--nopreview',
            '-o', '-'
        ], stdout=subprocess.PIPE, preexec_fn=os.setsid)
        atexit.register(stop_camera)

def stop_camera():
    global rpicam
    if rpicam and rpicam.poll() is None:
        try:
            os.killpg(rpicam.pid, signal.SIGTERM)
        except Exception:
            pass
        rpicam.wait(timeout=2)
        rpicam = None

def frame_generator():
    start_camera()
    while True:
        raw = rpicam.stdout.read(frame_size)
        if len(raw) != frame_size:
            break
        yuv = np.frombuffer(raw, dtype=np.uint8).reshape((height * 3 // 2, width))
        bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
        bgr = cv2.rotate(bgr, cv2.ROTATE_180)
        ok, jpeg = cv2.imencode('.jpg', bgr)
        if not ok:  # 프레임 인코딩 실패 시 skip
            continue
        yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' +
               jpeg.tobytes() + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(frame_generator(), mimetype='multipart/x-mixed-replace; boundary=frame')

# 정적 프런트 (한 페이지)
@app.route('/')
def index():
    return send_from_directory('static', 'index.html')

# ======= 텔레메트리 송신 루프 (예: python-can로 직접 읽음) =======
def telemetry_loop():
    if can is None:
        # python-can이 없다면, 데모/테스트로 가짜 데이터 송출
        t = 0
        while True:
            t += 1
            telemetry["rpm"] = (telemetry["rpm"] + 30) % 7000
            telemetry["speed_cms"] = min(telemetry["speed_cms"] + 5, 2800)
            telemetry["gear"] = 1
            telemetry["battery"] = max(0, 100 - (t // 50) % 101)
            socketio.emit('telemetry', telemetry, broadcast=True)
            socketio.sleep(0.1)
    else:
        # 실제 CAN 버스에서 읽어 파싱 (ID/포맷은 너의 규격에 맞게 변경)
        bus = can.interface.Bus(channel='can0', interface='socketcan')
        last_emit = 0
        while True:
            msg = bus.recv(timeout=0.05)  # non-blocking-ish
            if msg:
                # 예: 0x100 -> rpm(2바이트), 0x101 -> gear(1바이트)
                if msg.arbitration_id == 0x100 and msg.dlc >= 2:
                    rpm = (msg.data[0] << 8) | msg.data[1]
                    telemetry["rpm"] = int(rpm)

                    # 너의 C++과 동일한 속도 계산을 하려면 여기서도 수행하거나,
                    # 혹은 Pi의 다른 프로세스에서 값을 넘겨받아도 됨.
                    # 간단히 rpm -> cm/s 변환(예시):
                    wheel_diam_m = 0.068  # 6.8cm
                    meters_per_sec = (rpm / 60.0) * (np.pi * wheel_diam_m)
                    telemetry["speed_cms"] = int(round(meters_per_sec * 100.0))

                elif msg.arbitration_id == 0x101 and msg.dlc >= 1:
                    telemetry["gear"] = int(msg.data[0])

                # 배터리는 주기적으로 다른 곳에서 업데이트/emit 하거나, 여기서 처리
                # telemetry["battery"] = ...

            # 10Hz로만 브로드캐스트(emit 너무 자주하면 브라우저 FPS 떨어짐)
            now = time.time()
            if now - last_emit >= 0.1:
                socketio.emit('telemetry', telemetry) 
                last_emit = now
            socketio.sleep(0.01)

def main():
    print("Server on: http://0.0.0.0:8080")
    start_camera()
    # SocketIO 백그라운드 태스크로 텔레메트리 송신 시작
    socketio.start_background_task(telemetry_loop)
    socketio.run(app, host='0.0.0.0', port=8080)

if __name__ == '__main__':
    main()
