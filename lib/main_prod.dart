import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'firebase_options_prod.dart';

/// نقطة دخول بيئة الإنتاج (mada-prod).
/// التشغيل: flutter run -t lib/main_prod.dart
/// البناء:  flutter build apk --release -t lib/main_prod.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init(AppFlavor.prod);

  await Firebase.initializeApp(options: FirebaseOptionsProd.android);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MadaApp());
}
