import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/irrigation_provider.dart';

class IrrigationDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IrrigationProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Pillar 1: Smart Irrigation")),
      body: Column(
        children: [
          // Connection Status Banner
          Container(
            color: provider.systemStatus == "Normal" ? Colors.green : Colors.red,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            child: Text("System Status: ${provider.systemStatus}", 
                 textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
          ),
          
          // Moisture Gauge (Simplified)
          ListTile(
            title: Text("Soil Moisture"),
            subtitle: Text("${provider.moisture}%"),
            leading: Icon(Icons.water_drop, color: Colors.blue),
          ),

          // AI Reasoning Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI Reasoning (Llama-3)", style: TextStyle(fontWeight: FontWeight.bold)),
                  Divider(),
                  Text(provider.aiReasoning),
                  SizedBox(height: 10),
                  Text("Valve Angle: ${provider.valveAngle}°", 
                       style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}