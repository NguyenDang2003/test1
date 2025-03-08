import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _sliderValue = 0;
  final String serverIp = "192.168.1.100"; // Thay bằng IP Raspberry Pi

  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse("http://$serverIp:5000"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendPWM(double value) async {
    if (await checkServerConnection()) {
      await http.post(
        Uri.parse("http://$serverIp:5000/set_pwm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"duty_cycle": value * 100}),
      );
      print("Đã gửi PWM: ${value * 100}%");
    } else {
      print("Không kết nối được với Raspberry Pi!");
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
