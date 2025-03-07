import paho.mqtt.client as mqtt
import RPi.GPIO as GPIO
import time

# Cấu hình GPIO
GPIO_PIN = 18  # Chân GPIO để xuất điện áp
GPIO.setmode(GPIO.BCM)
GPIO.setup(GPIO_PIN, GPIO.OUT)

# Cấu hình PWM (Tần số 1000Hz)
pwm = GPIO.PWM(GPIO_PIN, 1000)
pwm.start(0)  # Ban đầu đặt duty cycle là 0%

BROKER = "localhost"
PORT = 1883
TOPIC = "slider/value"

# Khi kết nối MQTT thành công
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT Broker")
    client.subscribe(TOPIC)

# Khi nhận dữ liệu từ Flutter
def on_message(client, userdata, msg):
    try:
        value = float(msg.payload.decode())  # Nhận giá trị từ 0 - 100
        duty_cycle = value  # Điều chỉnh PWM
        pwm.ChangeDutyCycle(duty_cycle)
        print(f"Received: {value}% -> PWM: {duty_cycle}%")
    except Exception as e:
        print(f"Error: {e}")

# Khởi tạo MQTT Client
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER, PORT, 60)
client.loop_start()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("Stopping...")
    pwm.stop()
    GPIO.cleanup()
