import can

def main():
    # SocketCAN 인터페이스로 can0 읽기
    bus = can.interface.Bus(channel='can0', bustype='socketcan')

    print("Listening for CAN messages on can0...")

    while True:
        message = bus.recv()  # 메시지 수신 (blocking)
        if message.arbitration_id == 0x100 and message.dlc == 2:
            rpm = (message.data[0] << 8) | message.data[1]
            print(f"Received RPM: {rpm}")
        else:
            print(f"Other CAN msg: ID={hex(message.arbitration_id)}, Data={message.data}")

if __name__ == "__main__":
    main()
