import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    _progressController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {});
    });

    _progressController.forward();

    // After animation, we navigate to /login.
    // However, our GoRouter Redirect guard is watching.
    // If the user already has a token in secure storage, GoRouter 
    // will intercept this and instantly route them to /admin or /farmer!
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo placeholder (simulated with text and icon)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'agri',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    letterSpacing: -2,
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      's',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        letterSpacing: -2,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: -10,
                      child: Icon(
                        Icons.eco,
                        color: AppColors.primaryDark,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
              strokeWidth: 2,
            ),
            AppSpacing.h32,
            const Text(
              'INITIALIZING AI CORE',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.h16,
            SizedBox(
              width: 150,
              height: 2,
              child: LinearProgressIndicator(
                value: _progressController.value,
                backgroundColor: AppColors.surfaceBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
              ),
            ),
            AppSpacing.h48,
          ],
        ),
      ),
    );
  }
}
