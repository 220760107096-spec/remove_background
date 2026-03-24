import 'package:flutter/material.dart';

class AppColors {
  // Dark mode
  static const darkBg = Color(0xFF0A0A0F);
  static const darkSurface = Color(0xFF12121A);
  static const darkCard = Color(0xFF1A1A28);
  static const darkCardBorder = Color(0xFF2A2A40);

  // Light mode
  static const lightBg = Color(0xFFF0F2FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardBorder = Color(0xFFE0E4FF);

  // Accent colors
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFF9D5BFF);
  static const primaryDark = Color(0xFF5B21B6);
  static const accent = Color(0xFF06B6D4);
  static const accentGreen = Color(0xFF10B981);
  static const accentPink = Color(0xFFEC4899);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Gradient presets
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroBgGradientDark = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF12082A), Color(0xFF0A0A0F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroBgGradientLight = LinearGradient(
    colors: [Color(0xFFF0F2FF), Color(0xFFE8DEFF), Color(0xFFF0F8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    ),
    fontFamily: 'Inter',
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.darkCardBorder, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -1.0,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFB0B0C8),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF8080A0),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),
    fontFamily: 'Inter',
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.lightCardBorder, width: 1),
      ),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F0F23),
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F0F23),
        letterSpacing: -1.0,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F0F23),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF6060A0),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF9090B0),
      ),
    ),
  );
}
