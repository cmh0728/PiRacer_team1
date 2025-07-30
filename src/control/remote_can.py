import time
import can
from piracer.vehicles import PiRacerStandard
from piracer.gamepads import ShanWanGamepad

GEAR_NEUTRAL = 0x00
GEAR_DRIVE   = 0x01
GEAR_REVERSE = 0x02
GEAR_PARKING = 0x03

def main():
    print("""
            Start remote control. 
            A : move front 
            X : move rear
            Y : parking
            """)

    # CAN
    bus = can.interface.Bus(channel='can0', bustype='socketcan')

    gamepad = ShanWanGamepad()
    car     = PiRacerStandard()

    while True:
        inp = gamepad.read_data()
        if inp is None:
            time.sleep(0.01)
            continue

        # gear setting , have to checki joystick mapping
        if inp.button_a:
            throttle = +0.5
            gear     = GEAR_DRIVE # D
        elif inp.button_y:
            throttle = -0.5
            gear     = GEAR_REVERSE # R
        elif inp.button_x:
            print("PDC is on working")
            throttle = 0.0 
            gear = GEAR_PARKING # P will be edit later ( in pdc project )

        else:
            throttle = 0.0
            gear     = GEAR_NEUTRAL # N

        

        # stearing 
        steering = -inp.analog_stick_left.x

        # control
        car.set_throttle_percent(throttle)
        car.set_steering_percent(steering)

        msg = can.Message(arbitration_id=0x101, data=[gear], is_extended_id=False)
        try:
            bus.send(msg)
        except can.CanError:
            print("CAN send error")

if __name__ == '__main__':
    main()
