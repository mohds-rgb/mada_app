import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/providers/auth_session_provider.dart';
import 'core/providers/pin_gate_notifier.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/gen/app_localizations.dart';
import 'shared/widgets/platform_gate.dart';

/// نقطة تجميع التطبيق الموحَّد الواحد بأدواره الأربعة (بند 2، 3).
/// main_dev.dart / main_prod.dart يستدعيان initializeApp() فقط بعد تهيئة
/// Firebase بالخيارات الصحيحة لكل بيئة.
class MadaApp extends StatefulWidget {
  const MadaApp({super.key});

  @override
  State<MadaApp> createState() => _MadaAppState();
}

class _MadaAppState extends State<MadaApp> {
  late final AuthSessionNotifier _authNotifier;
  late final PinGateNotifier _pinGate;

  @override
  void initState() {
    super.initState();
    _authNotifier = AuthSessionNotifier();
    _pinGate = PinGateNotifier();
    // إعادة ضبط قفل PIN فور تسجيل الخروج — يمنع تجاوزه بإعادة دخول سريعة.
    _authNotifier.addListener(() {
      if (!_authNotifier.isSignedIn) _pinGate.reset();
    });
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    _pinGate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: AppConfig.instance.appTitle,
        debugShowCheckedModeBanner: AppConfig.instance.isDev,
        theme: AppTheme.light('ar'),
        darkTheme: AppTheme.dark('ar'),
        themeMode: ThemeMode.system, // بند 4: الوضع الفاتح إلزامي، يتبع النظام
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: buildAppRouter(_authNotifier, _pinGate),
        builder: (context, child) => PlatformGate(child: child!),
      ),
    );
  }
}
