from multiprocessing import Process, set_start_method
import signal, sys , os, subprocess

import src.camera_stream.camera_web  as cam #camera streaming
import src.control.remote_control as rm_control #remote control

CLUSTER_PATH = os.path.join(os.path.dirname(__file__),"src","Cluster","Cluster","build","ClusterApp")

def run_cluster():
    subprocess.run([CLUSTER_PATH],check=False)

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
    p3 = Process(target=run_cluster,name="head_u")

    all_process = [p1,p2,p3]
    for p in all_process: # all process start
        p.start()

    # press Ctrl+C to shutdown program
    def handler(sig, frame):
        print("\n[main] stopping...")
        shutdown([p1, p2])
        sys.exit(0)

    signal.signal(signal.SIGINT, handler) #catch Ctrl+c sign
    signal.signal(signal.SIGTERM, handler)

    for p in all_process:
        p.join()
    

if __name__ == "__main__":
    main()