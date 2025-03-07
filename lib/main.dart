import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runBackend();
  runApp(MyApp());
}

void runBackend() async {
  String backendPath =
      "backend/app.py"; // Đường dẫn backend trong dự án Flutter

  if (Platform.isWindows) {
    Process.start("python", [backendPath], mode: ProcessStartMode.detached);
  } else {
    Process.start("python3", [backendPath], mode: ProcessStartMode.detached);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _sliderValue = 0;
  final String serverIp = "127.0.0.1"; // Chạy backend trên cùng máy

  Future<void> sendPWM(double value) async {
    try {
      await http.post(
        Uri.parse("http://$serverIp:5000/set_pwm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"duty_cycle": value * 100}),
      );
    } catch (e) {
      print("Không kết nối được với Backend!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Điều khiển GPIO bằng Slider")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Điện áp: ${(_sliderValue * 3.3).toStringAsFixed(2)}V"),
              Slider(
                value: _sliderValue,
                min: 0,
                max: 1,
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                    sendPWM(value);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
