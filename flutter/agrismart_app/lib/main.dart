import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  // Attempt to read the token silently before app boots
  await authService.checkStoredToken();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const AgriSmartApp(),
    ),
  );
}

class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the auth service from Provider
    final authService = Provider.of<AuthService>(context, listen: false);
    // Initialize our GoRouter using the auth service
    final appRouter = AppRouter(authService).router;

    return MaterialApp.router(
      title: 'AgriSmart',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter, // Use GoRouter instead of static 'home:'
      debugShowCheckedModeBanner: false,
    );
  }
}






