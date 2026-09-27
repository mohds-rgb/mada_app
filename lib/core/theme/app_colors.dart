import 'package:flutter/material.dart';

/// ألوان الهوية البصرية الرسمية لـ MADA | مدى (بند 4 من مواصفة المشروع).
/// لا تُعدَّل هذه القيم — الهوية معتمدة ونهائية.
class AppColors {
  AppColors._();

  // الألوان الأساسية الرسمية
  static const Color navy = Color(0xFF0B1F3A); // أساسي
  static const Color turquoise = Color(0xFF00B8D9); // تمييز/أزرار
  static const Color gold = Color(0xFFD4AF6A); // تفاصيل فاخرة
  static const Color white = Color(0xFFF5F7FA); // نصوص/خلفيات فاتحة

  // درجات مشتقة للاستخدام العملي بالواجهات (داكن/فاتح)
  static const Color navyDark = Color(0xFF071527);
  static const Color navyLight = Color(0xFF16305A);
  static const Color turquoiseLight = Color(0xFF5CE1F0);
  static const Color surfaceDark = Color(0xFF0F2440);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // ألوان دلالية (حالات، بلاغات، SOS)
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE74C3C);
  static const Color sosRed = Color(0xFFD32F2F);

  static const Color textOnDark = white;
  static const Color textOnLight = navy;
  static const Color textMutedDark = Color(0xFFB6C2D9);
  static const Color textMutedLight = Color(0xFF5B6B85);

  // تدرج ناعم من Turquoise إلى Navy (طابع الواجهات، بند 4)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [turquoise, navy],
  );
}
