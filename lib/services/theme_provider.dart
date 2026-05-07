import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  /// 🔒 FORCE LIGHT MODE ONLY - No dark mode available
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => false; // Always false - light mode only

  ThemeProvider() {
    _loadTheme();
  }

  /// Load theme preference from storage
  /// 🔒 Always load as light mode (ignore stored preference if it's dark)
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Always force light mode
    _themeMode = ThemeMode.light;
    await prefs.setBool(_themeKey, false); // Store as light
    notifyListeners();
  }

  /// Toggle theme is DISABLED (always light)
  /// This method is kept for backward compatibility but does nothing
  Future<void> toggleTheme() async {
    // Intentionally disabled - light mode only
    notifyListeners();
  }

  /// Set theme explicitly - only allows light mode
  Future<void> setTheme(ThemeMode mode) async {
    // Force light mode regardless of input
    _themeMode = ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, false);
    notifyListeners();
  }

  /// 🌈 Magic Sky Light Theme (ONLY)
  /// Sử dụng Gradient, Shadows, và Typography từ Design System mới
  static ThemeData get lightTheme => MagicSkyTheme.lightTheme();

  /// 🔒 Dark Theme disabled - returns light theme
  static ThemeData get darkTheme => MagicSkyTheme.lightTheme();
}
