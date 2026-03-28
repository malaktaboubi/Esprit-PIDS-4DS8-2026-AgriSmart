import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

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

class AgriSmartApp extends StatefulWidget {
  const AgriSmartApp({super.key});

  @override
  State<AgriSmartApp> createState() => _AgriSmartAppState();
}

class _AgriSmartAppState extends State<AgriSmartApp> {
  late final GoRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _appRouter = AppRouter(authService).router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AgriSmart',
      theme: AppTheme.darkTheme,
      routerConfig: _appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}






