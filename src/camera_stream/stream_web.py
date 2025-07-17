import subprocess
import cv2
import numpy as np
from flask import Flask, Response

app = Flask(__name__)

# rpicam-vid subprocess 실행
rpicam = subprocess.Popen([
    'rpicam-vid',
    '--width', '640',
    '--height', '480',
    '--framerate', '30',
    '--codec', 'yuv420',
    '--timeout', '0',
    '--nopreview',
    '-o', '-'
], stdout=subprocess.PIPE)

width, height = 640, 480
frame_size = width * height * 3 // 2  # YUV420 크기

def generate():
    while True:
        raw_data = rpicam.stdout.read(frame_size)
        if len(raw_data) != frame_size:
            continue

        # YUV420 → BGR 변환
        yuv = np.frombuffer(raw_data, dtype=np.uint8).reshape((height * 3 // 2, width))
        bgr = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
        bgr = cv2.rotate(bgr, cv2.ROTATE_180)


        # JPEG 인코딩
        ret, jpeg = cv2.imencode('.jpg', bgr)
        if not ret:
            continue

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' +
               jpeg.tobytes() + b'\r\n')

@app.route('/')
def index():
    return '<h1>RPi Camera Stream</h1><img src="/video_feed" width="640" height="480">'

@app.route('/video_feed')
def video_feed():
    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
