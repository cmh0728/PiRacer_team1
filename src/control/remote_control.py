#from piracer.vehicles import PiRacerPro
from piracer.vehicles import PiRacerStandard
from piracer.gamepads import ShanWanGamepad


def main():
    shanwan_gamepad = ShanWanGamepad()
    # piracer = PiRacerPro()
    piracer = PiRacerStandard()

    while True:
        gamepad_input = shanwan_gamepad.read_data()

        
        try:
            throttle = (gamepad_input.button_y or 0) * 0.5 # y-> a
        except AttributeError:
            throttle = 0

        steering = -gamepad_input.analog_stick_left.x

        print(f'throttle={throttle}, steering={steering}')

        piracer.set_throttle_percent(throttle)
        piracer.set_steering_percent(steering)

if __name__ == '__main__':
    main()
