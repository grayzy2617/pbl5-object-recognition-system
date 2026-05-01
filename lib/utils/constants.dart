// lib/utils/constants.dart
class AppConstants {
  // API Configuration
  static const String serverBaseUrl = "http://192.168.3.100:5000";

  // API Endpoints
  static const String endpointRegister = "/register";
  static const String endpointLogin = "/login";
  static const String endpointProfile = "/profile";
  static const String endpointProfileAvatar = "/profile/avatar";
  static const String endpointProfileStats = "/profile/stats";
  static const String endpointQuizGenerate = "/quiz/generate";
  static const String endpointQuizSubmit = "/quiz/submit";
  static const String endpointHistory = "/history";
  static const String endpointDictionary = "/dictionary";

  // Storage Keys
  static const String storageKeyToken = "auth_token";
  static const String storageKeyTheme = "theme_mode";
  static const String storageKeyUserId = "user_id";

  // Quiz Configuration
  static const int defaultQuizLimit = 5;
  static const int pointsPerCorrectAnswer = 10;

  // Theme Configuration
  static const String primaryColorHex = "6200EE";
  static const String secondaryColorHex = "03DAC6";
  static const String errorColorHex = "CF6679";

  // App Strings
  static const String appName = "Smart Vocabulary Learning";
  static const String appVersion = "1.0.0";

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration animationDuration = Duration(milliseconds: 500);
}

// lib/utils/validators.dart
class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }

    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final emailRegex = RegExp(emailPattern);

    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu không khớp';
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên đăng nhập';
    }

    if (value.length < 3) {
      return 'Tên đăng nhập phải có ít nhất 3 ký tự';
    }

    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }

    if (value.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }
}

// lib/utils/extensions.dart
extension StringExtensions on String {
  /// Check if string is valid email
  bool isValidEmail() {
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailPattern).hasMatch(this);
  }

  /// Check if string is valid password
  bool isValidPassword() => length >= 6;

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Remove extra spaces
  String removeExtraSpaces() => replaceAll(RegExp(r'\s+'), ' ').trim();
}

extension DateTimeExtensions on DateTime {
  /// Format date to readable string (dd/MM/yyyy HH:mm)
  String toFormattedString() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year '
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Check if date is today
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension NumExtensions on num {
  /// Format percentage to 1 decimal place
  String toPercentageString() => '${toStringAsFixed(1)}%';

  /// Format large numbers with thousand separator
  String toFormattedString() {
    return toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (Match m) => ',',
    );
  }
}

extension DurationExtensions on Duration {
  /// Format duration to readable string
  String toFormattedString() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

extension ListExtensions<T> on List<T> {
  /// Get safe item at index
  T? getAtIndex(int index) {
    try {
      return this[index];
    } catch (e) {
      return null;
    }
  }

  /// Check if list is empty or null
  bool get isEmptyOrNull => isEmpty;

  /// Check if list has items
  bool get hasItems => isNotEmpty;
}

extension MapExtensions<K, V> on Map<K, V> {
  /// Get safe value for key
  V? getValueSafe(K key) {
    try {
      return this[key];
    } catch (e) {
      return null;
    }
  }

  /// Convert to JSON string
  String toJsonString() {
    return toString();
  }
}

extension IntExtensions on int {
  /// Format as currency
  String toCurrency({String symbol = '₫'}) {
    return '$symbol${toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => ',')}';
  }

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;
}

extension DoubleExtensions on double {
  /// Round to specific decimal places
  double roundToDecimal(int decimals) {
    final mod = 10.0 * decimals;
    return (this * mod).round() / mod;
  }

  /// Format as percentage
  String toPercentage({int decimals = 1}) =>
      '${roundToDecimal(decimals).toStringAsFixed(decimals)}%';

  /// Check if approximately equal
  bool isApproximatelyEqual(double other, {double tolerance = 0.0001}) {
    return (this - other).abs() <= tolerance;
  }
}

// lib/utils/helpers.dart
class DateTimeHelper {
  /// Get formatted date relative to now (e.g., "Today", "Yesterday", "2 days ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }
}

class NetworkHelper {
  /// Check if URL is valid
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class TextHelper {
  /// Truncate text to specific length with ellipsis
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0].toUpperCase()}${parts[1][0].toUpperCase()}';
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
