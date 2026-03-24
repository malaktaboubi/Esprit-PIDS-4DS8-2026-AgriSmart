import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  // Set with: flutter run --dart-define=API_BASE_URL=http://<host>/api/v1/auth
  // Default targets Android emulator's host loopback.
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/api/v1/auth',
  );
  final _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;

  Future<void> checkStoredToken() async {
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');
    
    if (token != null && role != null) {
      _isAuthenticated = true;
      _userRole = role;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        // OAuth2 standard requires sending data as form parts
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final role = data['role'];

        // Save token & role securely!
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_role', value: role);

        _isAuthenticated = true;
        _userRole = role;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'region': region,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        // Automatically login after successful registration
        return await login(email, password);
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    _isAuthenticated = false;
    _userRole = null;
    notifyListeners();
  }
}
