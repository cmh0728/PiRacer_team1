# Copyright (C) 2022 twyleg
import os
import pathlib
import time
import subprocess
from piracer.vehicles import PiRacerBase, PiRacerStandard

FILE_DIR = pathlib.Path(os.path.abspath(os.path.dirname(__file__)))

def get_ip_address():
    try:
        result = subprocess.run(["hostname", "-I"], capture_output=True, text=True)
        return result.stdout.strip().split()[0]  
    except:
        return "No IP"

def print_battery_report(vehicle: PiRacerBase):
    battery_voltage = vehicle.get_battery_voltage()
    battery_current = vehicle.get_battery_current()
    power_consumption = vehicle.get_power_consumption()
    ip_address = get_ip_address()

    display = vehicle.get_display()

    output_text = (
        'U={0:0>6.3f}V\n'
        'I={1:0>8.3f}mA\n'
        'P={2:0>6.3f}W\n'
        '{3}'.format(battery_voltage, battery_current, power_consumption, ip_address)
    )

    display.fill(0)
    display.text(output_text, 0, 0, 'white', font_name=FILE_DIR / 'fonts/font5x8.bin')
    display.show()

if __name__ == '__main__':
    piracer = PiRacerStandard()
    while True:
        print_battery_report(piracer)
        time.sleep(0.5)
