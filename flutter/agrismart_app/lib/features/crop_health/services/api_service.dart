import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../auth/services/auth_service.dart';
import '../models/diagnosis.dart';

class CropHealthApiService {
  // Set with: flutter run --dart-define=API_BASE_URL=http://<host>/api/v1/auth
  // We strip the /auth part to get the base API URL
  static final String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2/api/v1',
  ).replaceAll('/auth', '') + '/crop_health';

  String getFullImageUrl(String relativePath) {
    if (relativePath.startsWith('http')) return relativePath;
    // Extract the origin (e.g. https://abc.ngrok.app) and append the relative path
    try {
      final uri = Uri.parse(_baseUrl);
      return '${uri.origin}$relativePath';
    } catch (_) {
      return _baseUrl.replaceAll('/crop_health', '') + relativePath;
    }
  }

  final AuthService _authService;

  CropHealthApiService(this._authService);

  Future<List<Diagnosis>> fetchMyHistory() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl/diagnoses'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Diagnosis.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  Future<bool> uploadDiagnosis({
    required File imageFile,
    required String plantName,
    required String diseaseName,
    required double confidence,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/diagnoses'),
      );

      // Add Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add Fields
      request.fields['plant_name'] = plantName;
      request.fields['disease_name'] = diseaseName;
      request.fields['confidence'] = confidence.toString();

      // Add File
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error uploading diagnosis: $e');
      return false;
    }
  }

  Future<bool> deleteDiagnosis(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$_baseUrl/diagnoses/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting diagnosis: $e');
      return false;
    }
  }
}
