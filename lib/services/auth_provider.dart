import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthProvider() {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    final token = await ApiService.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }

  /// Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String bio = "",
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        bio: bio,
      );

      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Đăng ký thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.login(
        username: username,
        password: password,
      );

      if (result['success']) {
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Đăng nhập thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get user profile
  /// Get user profile
  Future<void> fetchUserProfile() async {
    // FIX LỖI: Trì hoãn việc update UI một chút để chờ Flutter vẽ xong khung hình hiện tại
    Future.microtask(() {
      _isLoading = true;
      _error = null;
      notifyListeners();
    });

    try {
      final result = await ApiService.getProfile();

      // Sau khi gọi API (có await) thì luồng này đã an toàn, có thể dùng notifyListeners bình thường
      if (result['success']) {
        _userProfile = result;
        _isLoading = false;
      } else {
        _error = result['error'] ?? 'Không thể tải hồ sơ';
        _isLoading = false;
        if (result['tokenExpired'] == true) {
          _isAuthenticated = false;
        }
      }
    } catch (e) {
      _error = 'Lỗi: ${e.toString()}';
      _isLoading = false;
    }

    notifyListeners();
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    required String bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.updateProfile(
        fullName: fullName,
        bio: bio,
      );

      if (result['success']) {
        _userProfile = result;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Cập nhật thất bại';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Lỗi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await ApiService.removeToken();
    _isAuthenticated = false;
    _userProfile = null;
    _error = null;
    _isLoading = false;

    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
