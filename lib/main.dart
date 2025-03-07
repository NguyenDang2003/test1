import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:process_run/process_run.dart';

void main() {
  runBackend(); // Chạy backend khi mở app
  runApp(MyApp());
}

// Hàm khởi động backend
void runBackend() async {
  String scriptPath = "backend/backend.py"; // Đường dẫn file backend.py
  Process.start('python3', [scriptPath])
      .then((Process process) {
        print("Backend started with PID: ${process.pid}");
      })
      .catchError((e) {
        print("Failed to start backend: $e");
      });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MqttServerClient client;
  double sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    connectMQTT();
  }

  Future<void> connectMQTT() async {
    client = MqttServerClient('your_raspberry_ip', '');
    client.port = 1883;
    client.logging(on: false);
    client.onConnected = () => print('Connected to MQTT');
    client.onDisconnected = () => print('Disconnected from MQTT');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('FlutterClient')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
    }
  }

  void sendMessage(double value) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(value.toString());
    client.publishMessage('slider/value', MqttQos.atMostOnce, builder.payload!);
    print("Sent: $value%");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('PWM Control via MQTT')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Adjust Voltage: ${sliderValue.toStringAsFixed(1)}%"),
            Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: sliderValue.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  sliderValue = value;
                });
                sendMessage(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
