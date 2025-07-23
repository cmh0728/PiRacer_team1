#!/usr/bin/env python3
import can

def main():
    # SocketCAN can0 인터페이스 열기
    bus = can.interface.Bus(channel='can0', bustype='socketcan')

    print("Listening for wheel RPM on CAN ID 0x100...")
    try:
        while True:
            msg = bus.recv()  # 블로킹 수신
            if msg is None:
                continue

            # ID 필터
            if msg.arbitration_id == 0x100 and len(msg.data) >= 2:
                # 상위바이트<<8 | 하위바이트 (big-endian)
                raw = (msg.data[0] << 8) | msg.data[1]
                # 그대로 RPM이라고 가정
                rpm = raw
                print(f"rpm : {rpm}")
    except KeyboardInterrupt:
        print("\nExiting.")

if __name__ == "__main__":
    main()
