import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_colors.dart';

/// 🌈 Magic Sky App Theme
/// Thiết kế riêng cho trẻ em với Typography, Components, và Colors
class MagicSkyTheme {
  /// Light Theme (ONLY LIGHT MODE - No Dark Mode)
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ==================== COLOR SCHEME ====================
      colorScheme: ColorScheme.light(
        primary: MagicSkyColors.primaryBlue,
        secondary: MagicSkyColors.sunsetOrange,
        tertiary: const Color(0xFFE8D5FF),
        surface: MagicSkyColors.bgWhite,
        error: MagicSkyColors.warningCoral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: MagicSkyColors.textDarkNavy,
        onError: Colors.white,
      ),

      // ==================== SCAFFOLD ====================
      scaffoldBackgroundColor: MagicSkyColors.bgSoftWhite,

      // ==================== APP BAR ====================
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: MagicSkyColors.textDarkNavy,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 64,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        iconTheme: const IconThemeData(
          color: MagicSkyColors.primaryBlue,
          size: 28,
        ),
      ),

      // ==================== BOTTOM NAVIGATION ====================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: MagicSkyColors.primaryBlue,
        unselectedItemColor: MagicSkyColors.textLightGrey,
        elevation: 16,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ==================== BOTTOM SHEET ====================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),

      // ==================== CARDS ====================
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: const Color(0xFF000000).withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ==================== BUTTONS ====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MagicSkyColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shadowColor: MagicSkyColors.primaryColoredShadow.color,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MagicSkyColors.primaryBlue,
          textStyle: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MagicSkyColors.primaryBlue,
          side: const BorderSide(color: MagicSkyColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==================== INPUT DECORATION ====================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: MagicSkyColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: MagicSkyColors.warningCoral,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: MagicSkyColors.warningCoral,
            width: 2,
          ),
        ),
        hintStyle: GoogleFonts.quicksand(
          color: MagicSkyColors.textLightGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: GoogleFonts.quicksand(
          color: MagicSkyColors.textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: GoogleFonts.quicksand(
          color: MagicSkyColors.warningCoral,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: MagicSkyColors.primaryBlue,
        suffixIconColor: MagicSkyColors.primaryBlue,
      ),

      // ==================== TYPOGRAPHY ====================
      textTheme: TextTheme(
        // Display Large
        displayLarge: GoogleFonts.quicksand(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Display Medium
        displayMedium: GoogleFonts.quicksand(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Display Small
        displaySmall: GoogleFonts.quicksand(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Headline Large
        headlineLarge: GoogleFonts.quicksand(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Headline Medium
        headlineMedium: GoogleFonts.quicksand(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Headline Small
        headlineSmall: GoogleFonts.quicksand(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Title Large
        titleLarge: GoogleFonts.quicksand(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Title Medium
        titleMedium: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Title Small
        titleSmall: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Body Large
        bodyLarge: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Body Medium
        bodyMedium: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MagicSkyColors.textGrey,
        ),
        // Body Small
        bodySmall: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: MagicSkyColors.textLightGrey,
        ),
        // Label Large
        labelLarge: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MagicSkyColors.textDarkNavy,
        ),
        // Label Medium
        labelMedium: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: MagicSkyColors.textGrey,
        ),
        // Label Small
        labelSmall: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MagicSkyColors.textLightGrey,
        ),
      ),

      // ==================== PROGRESS & SLIDERS ====================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MagicSkyColors.primaryBlue,
        linearMinHeight: 6,
        // circularTrackHeight: 4,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: MagicSkyColors.primaryBlue,
        inactiveTrackColor: const Color(0xFFE5E7EB),
        thumbColor: MagicSkyColors.primaryBlue,
        overlayColor: MagicSkyColors.primaryBlue.withValues(alpha: 0.2),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),

      // ==================== CHIPS ====================
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: MagicSkyColors.primaryBlue,
        disabledColor: const Color(0xFFE5E7EB),
        labelStyle: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MagicSkyColors.textDarkNavy,
        ),
        secondaryLabelStyle: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),

      // ==================== DIALOG ====================
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: MagicSkyColors.textDarkNavy,
        ),
        contentTextStyle: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MagicSkyColors.textGrey,
        ),
      ),

      // ==================== SNACKBAR ====================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MagicSkyColors.textDarkNavy,
        contentTextStyle: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        behavior: SnackBarBehavior.floating,
      ),

      // ==================== SWITCH & CHECKBOX ====================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MagicSkyColors.primaryBlue;
          }
          return const Color(0xFF9CA3AF);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MagicSkyColors.primaryBlue.withValues(alpha: 0.3);
          }
          return const Color(0xFFD1D5DB).withValues(alpha: 0.3);
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MagicSkyColors.primaryBlue;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 2),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),

      // ==================== TAB BAR ====================
      tabBarTheme: TabBarThemeData(
        labelColor: MagicSkyColors.primaryBlue,
        unselectedLabelColor: MagicSkyColors.textLightGrey,
        labelStyle: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: MagicSkyColors.primaryBlue,
            width: 3,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
