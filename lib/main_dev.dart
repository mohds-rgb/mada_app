import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'firebase_options_dev.dart';

/// نقطة دخول بيئة التطوير (mada-dev-5ca8e).
/// التشغيل: flutter run -t lib/main_dev.dart
/// البناء:  flutter build apk --debug -t lib/main_dev.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init(AppFlavor.dev);

  await Firebase.initializeApp(options: FirebaseOptionsDev.android);

  // Crashlytics: يلتقط كل الأخطاء غير المعالجة (مجاني على Spark — بند 5).
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MadaApp());
}
