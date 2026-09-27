import 'package:flutter/material.dart';
import 'app_colors.dart';

/// أنماط النصوص — Tajawal للعربي (يُطبَّق تلقائياً عبر ThemeData.fontFamily
/// حسب اللغة الحالية)، وMontserrat للإنجليزي (بند 4).
/// نستخدم الخطوط المحلية المرفقة في assets/fonts لضمان العمل بلا اتصال إنترنت.
class AppTextStyles {
  AppTextStyles._();

  static const String arabicFontFamily = 'Tajawal';
  static const String englishFontFamily = 'Montserrat';

  /// يُعيد اسم عائلة الخط المناسبة حسب رمز اللغة الحالي.
  static String fontFamilyFor(String languageCode) {
    return languageCode == 'ar' ? arabicFontFamily : englishFontFamily;
  }

  static TextTheme textTheme(String languageCode, Color baseColor) {
    final family = fontFamilyFor(languageCode);
    return TextTheme(
      displayLarge: TextStyle(fontFamily: family, fontSize: 32, fontWeight: FontWeight.w700, color: baseColor),
      headlineMedium: TextStyle(fontFamily: family, fontSize: 24, fontWeight: FontWeight.w700, color: baseColor),
      titleLarge: TextStyle(fontFamily: family, fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
      titleMedium: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
      bodyLarge: TextStyle(fontFamily: family, fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
      labelLarge: TextStyle(fontFamily: family, fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      bodySmall: TextStyle(fontFamily: family, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMutedDark),
    );
  }
}
