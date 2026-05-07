import 'package:flutter/material.dart';

/// 🌈 Magic Sky Color System
/// Design System cho trẻ em với gradient, shadows, và animations
class MagicSkyColors {
  // ==================== PRIMARY GRADIENTS ====================
  /// Gradient Xanh Ngọc Bích → Xanh Dương Tươi (chủ đạo)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient Xanh Dương → Xanh Lam (darker)
  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFF0099FF), Color(0xFF0057D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== ACCENT GRADIENTS ====================
  /// Gradient Cam Hoàng Hôn → Vàng Chanh (nút bấm, highlight)
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF8C3A), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient Cam Đỏ → Vàng cam (hover state)
  static const LinearGradient sunsetGradientDark = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== TERTIARY GRADIENTS ====================
  /// Gradient Lavender → Soft Pink (secondary info)
  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [Color(0xFFE8D5FF), Color(0xFFFFD6E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient Mint Green → Cyan (success)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient Coral → Red (warning/danger)
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF4757)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== BACKGROUND GRADIENTS ====================
  /// Gradient nền trang (Xanh nhạt → Tím nhạt)
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF0F9FF), Color(0xFFFAF5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== SOLID COLORS ====================
  // Primary
  static const Color primaryCyan = Color(0xFF00D4FF);
  static const Color primaryBlue = Color(0xFF0099FF);
  static const Color primaryDarkBlue = Color(0xFF0057D8);

  // Accent
  static const Color sunsetOrange = Color(0xFFFF8C3A);
  static const Color sunshineYellow = Color(0xFFFFD700);

  // Text
  static const Color textDarkNavy = Color(0xFF1A365D);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLightGrey = Color(0xFF9CA3AF);

  // Background
  static const Color bgSoftWhite = Color(0xFFF8FAFC);
  static const Color bgWhite = Color(0xFFFFFFFF);

  // Success & States
  static const Color successMint = Color(0xFF2DD4BF);
  static const Color warningCoral = Color(0xFFFF6B6B);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Streak & Gamification
  static const Color streakFire = Color(0xFFFF6B35); // 🔥 Đỏ cam
  static const Color titleGold = Color(0xFFFFD700); // 👑 Vàng
  static const Color titleSilver = Color(0xFFC0C0C0); // 🥈 Bạc
  static const Color titleBronze = Color(0xFFCD7F32); // 🥉 Đồng
  static const Color titleDiamond = Color(0xFF00D4FF); // 💎 Kim cương
  static const Color titleLegend = Color(0xFF9333EA); // 👑 Huyền thoại

  // ==================== SHADOWS ====================
  /// Soft shadow với màu sắc nhẹ nhàng
  static final BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF000000).withValues(alpha: 0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );

  /// Shadow nâng cao 3D
  static final BoxShadow elevatedShadow = BoxShadow(
    color: const Color(0xFF000000).withValues(alpha: 0.12),
    blurRadius: 20,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );

  /// Shadow với màu gradient (primary)
  static final BoxShadow primaryColoredShadow = BoxShadow(
    color: const Color(0xFF0099FF).withValues(alpha: 0.2),
    blurRadius: 16,
    offset: const Offset(0, 6),
    spreadRadius: 0,
  );

  /// Shadow với màu sunset
  static final BoxShadow sunsetColoredShadow = BoxShadow(
    color: const Color(0xFFFF8C3A).withValues(alpha: 0.2),
    blurRadius: 16,
    offset: const Offset(0, 6),
    spreadRadius: 0,
  );

  /// Shadow nhẹ cho card
  static final List<BoxShadow> cardShadows = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Shadow nâng cao cho modal/dialog
  static final List<BoxShadow> modalShadows = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // ==================== OPACITY & TRANSPARENCY ====================
  static const double opacityHigh = 0.8;
  static const double opacityMedium = 0.5;
  static const double opacityLow = 0.2;
  static const double opacityVeryLow = 0.1;

  // ==================== HELPER METHODS ====================
  /// Lấy màu Streak dựa trên con số
  static Color getStreakColor(int streak) {
    if (streak >= 100) return titleLegend;
    if (streak >= 50) return titleDiamond;
    if (streak >= 20) return titleGold;
    if (streak >= 10) return sunsetOrange;
    return successMint;
  }

  /// Lấy màu Title dựa trên tên
  static Color getTitleColor(String titleName) {
    if (titleName.contains('Huyền thoại')) return titleLegend;
    if (titleName.contains('Kim Cương')) return titleDiamond;
    if (titleName.contains('Vàng')) return titleGold;
    if (titleName.contains('Bạc')) return titleSilver;
    if (titleName.contains('Đồng')) return titleBronze;
    return successMint;
  }
}
