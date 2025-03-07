class Pi:
    def set_mode(self, pin, mode):
        print(f"Set GPIO {pin} to mode {mode}")

    def set_PWM_frequency(self, pin, freq):
        print(f"Set PWM frequency {freq}Hz on GPIO {pin}")

    def set_PWM_dutycycle(self, pin, duty_cycle):
        print(f"Set duty cycle {duty_cycle} on GPIO {pin}")

def pi():
    return Pi()
