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
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  String? get userRole => _userRole;

  Future<void> checkStoredToken() async {
    final token = await _storage.read(key: 'jwt_token');
    final role = await _storage.read(key: 'user_role');

    if (token != null && role != null) {
      _isAuthenticated = true;
      _userRole = role;
      _token = token;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    return _token ?? await _storage.read(key: 'jwt_token');
  }

  Future<String?> login(String email, String password) async {
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
        _token = token;
        notifyListeners();
        return null; // Return null string to indicate success
      }

      try {
        final data = jsonDecode(response.body);
        final detail = data['detail'];
        if (detail == 'Inactive user') {
          return 'Access Denied: Your account has been disabled by an admin.';
        } else if (detail == 'Incorrect email or password') {
          return 'Invalid credentials, please check your email and password.';
        } else if (detail != null) {
          return detail.toString();
        }
      } catch (_) {}

      return 'Authentication failed. Please verify your data and try again.';
    } catch (e) {
      debugPrint('Login error: $e');
      return 'Network error: Could not reach the server. Check your connection.';
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
        final loginError = await login(email, password);
        return loginError == null;
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
    _token = null;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchAdminUsers() async {
    final token = _token ?? await _storage.read(key: 'jwt_token');
    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.whereType<Map<String, dynamic>>().toList();
      }

      return [];
    } catch (e) {
      debugPrint('Fetch users error: $e');
      return [];
    }
  }

  Future<bool> createUserByAdmin({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String role,
  }) async {
    final token = _token ?? await _storage.read(key: 'jwt_token');
    if (token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Create user error: $e');
      return false;
    }
  }

  Future<bool> updateUserRoleAccess({
    required int userId,
    String? role,
    bool? isActive,
  }) async {
    final token = _token ?? await _storage.read(key: 'jwt_token');
    if (token == null) {
      return false;
    }

    try {
      final payload = <String, dynamic>{};
      if (role != null) {
        payload['role'] = role;
      }
      if (isActive != null) {
        payload['is_active'] = isActive;
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update user error: $e');
      return false;
    }
  }
}
