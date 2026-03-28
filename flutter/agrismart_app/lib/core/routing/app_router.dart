import 'package:agrismart_app/features/auth/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/consultant/screens/consultant_dashboard_screen.dart';
import '../../features/crop_health/screens/crop_health_container.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final router = GoRouter(
    initialLocation: '/splash',
    // The refreshListenable ensures that if authService calls notifyListeners()
    // (like during logout), the router will re-evaluate its state and redirect!
    refreshListenable: authService,

    // THE REDIRECT GUARD: This is where the magic happens from your diagram
    redirect: (context, state) {
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isSplash = state.matchedLocation == '/splash';
      final bool isSignUp = state.matchedLocation == '/signup';
      
      // If they are not authenticated and not already on the login, signup, or splash screen
      if (!authService.isAuthenticated && !isLoggingIn && !isSignUp && !isSplash) {
        return '/login';
      }

      // If they ARE authenticated, we decide WHERE they should go based on the role
      if (authService.isAuthenticated) {
        // If they are trying to go to login or splash, redirect to their dashboards
        if (isLoggingIn || isSignUp || isSplash) {
          if (authService.userRole == 'consultant') {
            return '/consultant';
          } else {
            // Default farmer
            return '/farmer';
          }
        }
      }

      return null; // Return null means "no redirect needed, continue as normal"
    },
    
    // Define all our available screens
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/consultant',
        builder: (context, state) => const ConsultantDashboardScreen(),
      ),
      GoRoute(
        path: '/farmer',
        builder: (context, state) => const FarmerHomeScreen(),
      ),
      GoRoute(
        path: '/crop-health',
        builder: (context, state) => const CropHealthContainer(),
      ),
    ],
  );
}
