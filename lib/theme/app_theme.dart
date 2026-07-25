import 'package:flutter/material.dart';

class AppColors {
  static const Color brandGreen = Color(0xFF20D99B);
  static const Color brandCyan = Color(0xFF23C7CF);
  static const Color brandBlue = Color(0xFF3D7BFF);

  static const Color darkNavy = Color(0xFF070B2D);
  static const Color darkCard = Color(0xFF0A0E3B);

  static const Color textPrimary = Color(0xFF10142F);
  static const Color textSecondary = Color(0xFF687086);

  static const Color softBg = Color(0xFFF6F8FC);
  static const Color card = Colors.white;
  static const Color stroke = Color(0xFFE9EEF7);

  static const Color success = Color(0xFF27C46B);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF4D4F);
}

class AppGradients {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.brandGreen,
      AppColors.brandCyan,
      AppColors.brandBlue,
    ],
  );

  static const LinearGradient premiumDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.darkNavy,
      AppColors.darkCard,
      Color(0xFF17216A),
    ],
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.softBg,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.light,
        primary: AppColors.brandGreen,
        secondary: AppColors.brandBlue,
        surface: AppColors.card,
        error: AppColors.danger,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.08,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.12,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: AppColors.textSecondary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF050816),
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.dark,
        primary: AppColors.brandGreen,
        secondary: AppColors.brandBlue,
        surface: const Color(0xFF0B1024),
        error: AppColors.danger,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.08,
          color: Color(0xFFF4F7FF),
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.12,
          color: Color(0xFFF4F7FF),
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFFF4F7FF),
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF4F7FF),
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: Color(0xFFF4F7FF),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
          color: Color(0xFFAAB3C8),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.30,
          color: Color(0xFFAAB3C8),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFAAB3C8),
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFF4F7FF)),
      dividerColor: const Color(0xFF202943),
    );
  }

}
