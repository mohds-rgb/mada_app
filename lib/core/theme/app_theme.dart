import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// الثيمات الرسمية لتطبيق MADA — داكن (افتراضي) وفاتح (بند 4: إلزامي).
/// يتبع النظام تلقائياً أو يُختار يدوياً من الإعدادات (يُنفَّذ لاحقاً عبر Riverpod).
class AppTheme {
  AppTheme._();

  static ThemeData dark(String languageCode) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navyDark,
      primaryColor: AppColors.turquoise,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.turquoise,
        secondary: AppColors.gold,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.navy,
        onSurface: AppColors.textOnDark,
      ),
      textTheme: AppTextStyles.textTheme(languageCode, AppColors.textOnDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamilyFor(languageCode),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turquoise,
          foregroundColor: AppColors.navy,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(
            fontFamily: AppTextStyles.fontFamilyFor(languageCode),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: AppColors.navyLight,
    );
  }

  static ThemeData light(String languageCode) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.navy,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.navy,
        secondary: AppColors.turquoise,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSurface: AppColors.textOnLight,
      ),
      textTheme: AppTextStyles.textTheme(languageCode, AppColors.textOnLight),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textOnLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.fontFamilyFor(languageCode),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turquoise,
          foregroundColor: AppColors.navy,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: TextStyle(
            fontFamily: AppTextStyles.fontFamilyFor(languageCode),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F2F7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: AppColors.textMutedLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: const Color(0xFFE1E5EC),
    );
  }
}
