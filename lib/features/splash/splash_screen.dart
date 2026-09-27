import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/route_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/mada_logo.dart';

/// Splash — شعار MADA + نص الملكية (بند 0، 3-أ-1).
/// يقرأ محلياً هل أنهى المستخدم Onboarding سابقاً؛ إن لا، يوجّهه له، وإلا
/// AuthSessionNotifier (عبر GoRouter redirect) يتكفّل بالباقي تلقائياً.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _onboardingSeenKey = 'onboarding_seen';

  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    await Future.delayed(const Duration(milliseconds: 900)); // لحظة عرض الشعار
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool(_onboardingSeenKey) ?? false;
    if (!mounted) return;

    if (!seenOnboarding) {
      context.go(RoutePaths.onboarding);
    } else {
      context.go(RoutePaths.login);
    }
    // ملاحظة: إن كان المستخدم مسجَّلاً دخوله فعلاً، redirect بـGoRouter
    // (app_router.dart) سيعيد توجيهه تلقائياً من login لواجهته الصحيحة —
    // لا حاجة لأي منطق تكرار هنا.
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MadaLogo(size: 140),
            SizedBox(height: 24),
            Text(
              'مدى | MADA',
              style: TextStyle(color: AppColors.textOnDark, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('كل وجهة أقرب', style: TextStyle(color: AppColors.textMutedDark, fontSize: 14)),
            SizedBox(height: 40),
            Text(
              '© M&M TECH — جميع الحقوق محفوظة',
              style: TextStyle(color: AppColors.textMutedDark, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
