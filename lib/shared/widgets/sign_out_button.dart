import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// زر "تسجيل خروج" موحَّد — متاح بإعدادات كل واجهة (بند 3-ج).
class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: 'تسجيل خروج',
      onPressed: () => FirebaseAuth.instance.signOut(),
      // لا تنقّل يدوي هنا — GoRouter redirect (app_router.dart) يلتقط
      // authStateChanges تلقائياً ويعيد التوجيه لشاشة الدخول.
    );
  }
}
