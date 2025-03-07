import sys
from flask import Flask, request, jsonify

# Kiểm tra nếu đang chạy trên Raspberry Pi
if sys.platform.startswith('linux') and 'raspberrypi' in open('/proc/cpuinfo').read():
    import pigpio
else:
    import backend.mock_pigpio as pigpio  # Giả lập trên Laptop

app = Flask(__name__)
pi = pigpio.pi()

PWM_PIN = 18
pi.set_mode(PWM_PIN, 1)
pi.set_PWM_frequency(PWM_PIN, 1000)

@app.route('/')
def home():
    return jsonify({"message": "Backend is running"}), 200

@app.route('/set_pwm', methods=['POST'])
def set_pwm():
    data = request.json
    duty_cycle = data.get("duty_cycle", 0)
    pi.set_PWM_dutycycle(PWM_PIN, int(duty_cycle * 255 / 100))
    return jsonify({"message": f"Set PWM to {duty_cycle}%"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
