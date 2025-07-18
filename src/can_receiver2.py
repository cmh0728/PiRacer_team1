import can

def main():
    # 'socketcan' 으로 바꿔주세요
    bus = can.Bus(channel='can0', interface='socketcan')

    print("Listening for CAN messages on can0...")
    while True:
        msg = bus.recv(timeout=1.0)
        if msg:
            id_type = "EXT" if msg.is_extended_id else "STD"
            data = " ".join(f"{b:02X}" for b in msg.data)
            print(f"[{id_type}] ID=0x{msg.arbitration_id:X} Data=[{data}]")

if __name__ == "__main__":
    main()
