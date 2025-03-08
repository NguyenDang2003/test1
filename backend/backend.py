from flask import Flask, request, jsonify
import pigpio

app = Flask(__name__)

# Kết nối với daemon pigpio
pi = pigpio.pi()

# Chân GPIO sử dụng (PWM)
PWM_PIN = 18
pi.set_mode(PWM_PIN, pigpio.OUTPUT)
pi.set_PWM_frequency(PWM_PIN, 1000)  # Cấu hình tần số PWM 1kHz

@app.route('/')
def home():
    return jsonify({"message": "Backend is running"}), 200

@app.route('/set_pwm', methods=['POST'])
def set_pwm():
    data = request.json
    duty_cycle = data.get("duty_cycle", 0)  # Giá trị từ 0 đến 100
    if 0 <= duty_cycle <= 100:
        pwm_value = int(duty_cycle * 255 / 100)  # Chuyển về thang 0-255
        pi.set_PWM_dutycycle(PWM_PIN, pwm_value)
        return jsonify({"message": f"Set PWM to {duty_cycle}%"}), 200
    return jsonify({"error": "Invalid duty cycle"}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
