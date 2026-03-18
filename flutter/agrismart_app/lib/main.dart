import 'package:flutter/material.dart';
import 'package:agrismart_app/core/theme/app_theme.dart';
import 'package:agrismart_app/features/auth/screens/splash_screen.dart';

void main() {
  runApp(const AgriSmartApp());
}

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriSmart',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}





