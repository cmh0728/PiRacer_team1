import subprocess
import atexit
import cv2, numpy as np
from flask import Flask, Response

width, height = 640, 480
frame_size = width * height * 3 // 2

rpicam = None
app = Flask(__name__)

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
        ], stdout=subprocess.PIPE)
        atexit.register(stop_camera)

def stop_camera():
    global rpicam
    if rpicam and rpicam.poll() is None:
        rpicam.terminate()
        rpicam.wait(timeout=2)
        rpicam = None

def frame_generator():
    start_camera()
    while True:
        raw = rpicam.stdout.read(frame_size)
        if len(raw) != frame_size:
            break  # or continue, depending on policy
        yuv = np.frombuffer(raw, dtype=np.uint8).reshape((height * 3 // 2, width))
        bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
        bgr = cv2.rotate(bgr, cv2.ROTATE_180)
        ok, jpeg = cv2.imencode('.jpg', bgr)
        if not ok:
            continue
        yield (b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' +
               jpeg.tobytes() + b'\r\n')

@app.route('/')
def index():
    return '<h1>RPi Camera Stream</h1><img src="/video_feed" width="640" height="480">'

@app.route('/video_feed')
def video_feed():
    return Response(frame_generator(), mimetype='multipart/x-mixed-replace; boundary=frame')

def main():
    print("Start Camera stream. port : 8080")
    start_camera()
    app.run(host='0.0.0.0', port=8080, debug=False)

if __name__ == '__main__':
    main()
