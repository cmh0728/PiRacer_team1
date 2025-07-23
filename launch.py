from multiprocessing import Process, set_start_method
import signal, sys

import src.camera_stream.camera_web  as cam #camera streaming
import src.control.remote_control as rm_control #remote control

def shutdown(procs):
    for p in procs:
        if p.is_alive():
            p.terminate()
    for p in procs:
        p.join()

def main():
    try:
        set_start_method("spawn")
    except RuntimeError:
        pass  

    p1 = Process(target=cam.main)
    p2 = Process(target=rm_control.main)

    p1.start()
    p2.start()

    # press Ctrl+C to shutdown program
    def handler(sig, frame):
        print("\n[main] stopping...")
        shutdown([p1, p2])
        sys.exit(0)

    signal.signal(signal.SIGINT, handler) #catch Ctrl+c sign
    signal.signal(signal.SIGTERM, handler)

    p1.join()
    p2.join()

if __name__ == "__main__":
    main()