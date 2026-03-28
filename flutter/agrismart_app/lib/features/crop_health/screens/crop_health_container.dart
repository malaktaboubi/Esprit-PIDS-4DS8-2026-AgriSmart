import 'package:flutter/material.dart';
import 'crop_health_screen.dart';
import 'history_screen.dart';

class CropHealthContainer extends StatefulWidget {
  const CropHealthContainer({super.key});

  @override
  State<CropHealthContainer> createState() => _CropHealthContainerState();
}

class _CropHealthContainerState extends State<CropHealthContainer> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const CropHealthScreen(), const CropHealthHistoryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Detect",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}
