import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class IrrigationProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  
  // State Variables
  double moisture = 0.0;
  double temperature = 0.0;
  int valveAngle = 0;
  String systemStatus = "Connecting...";
  String aiReasoning = "Waiting for data...";
  bool isConnected = false;

  void connect(String baseUrl) {
    // baseUrl should be your ngrok URL (e.g., 'a1b2.ngrok-free.app')
    final wsUrl = Uri.parse('ws://$baseUrl/ws/irrigation');
    _channel = WebSocketChannel.connect(wsUrl);
    isConnected = true;
    notifyListeners();

    _channel!.stream.listen(
      (message) {
        _handleIncomingData(message);
      },
      onDone: () {
        isConnected = false;
        systemStatus = "Disconnected";
        notifyListeners();
        // Optional: Implement auto-reconnect logic here
      },
      onError: (error) {
        print("WS Error: $error");
        isConnected = false;
        notifyListeners();
      },
    );
  }

  void _handleIncomingData(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    
    // Parse Sensor Data
    final sensors = data['sensor_data'];
    moisture = sensors['moisture'].toDouble();
    temperature = sensors['temp'].toDouble();

    // Parse AI Decision
    final ai = data['ai_decision'];
    valveAngle = ai['angle'];
    systemStatus = ai['status']; // "Normal", "LEAK_DETECTED", etc.
    aiReasoning = ai['reason'];

    notifyListeners();
  }

  void disposeConnection() {
    _channel?.sink.close();
    super.dispose();
  }
}