import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.3:5000";
  static const String tokenKey = "auth_token";
  static const String userIdKey = "user_id";

  // Get token from storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Save token to storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // Remove token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
  }

  // Helper method to build headers with JWT
  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ========== AUTH ENDPOINTS ==========

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String bio = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(requireAuth: false),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          'bio': bio,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Login user and get JWT token
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(requireAuth: false),
        body: jsonEncode({'username': username, 'password': password}),
      );

      final result = _handleResponse(response);

      // Save token if login successful
      if (result['success'] && result['token'] != null) {
        await saveToken(result['token']);
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== PROFILE ENDPOINTS ==========

  /// Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _getHeaders(requireAuth: true),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String bio,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/profile'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'full_name': fullName, 'bio': bio}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Upload avatar
  static Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {'success': true, ...jsonDecode(respStr)};
      } else {
        return {'success': false, 'error': jsonDecode(respStr)['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get profile stats
  static Future<Map<String, dynamic>> getProfileStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/stats'),
        headers: await _getHeaders(requireAuth: true),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== QUIZ ENDPOINTS ==========

  /// Generate quiz questions
  static Future<Map<String, dynamic>> generateQuiz({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/generate?limit=$limit'),
        headers: await _getHeaders(requireAuth: true),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Submit quiz answers
  static Future<Map<String, dynamic>> submitQuiz(
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/submit'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'answers': answers}),
      );

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== HISTORY & DICTIONARY ENDPOINTS ==========

  /// Get detection history
  static Future<Map<String, dynamic>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: await _getHeaders(requireAuth: true),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get dictionary
  static Future<Map<String, dynamic>> getDictionary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dictionary'),
        headers: await _getHeaders(requireAuth: false),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== HELPER METHODS ==========

  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, ...data};
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        removeToken();
        return {
          'success': false,
          'error': 'Token hết hạn. Vui lòng đăng nhập lại.',
          'tokenExpired': true,
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Lỗi máy chủ'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
