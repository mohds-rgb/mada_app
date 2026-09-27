import 'main_dev.dart' as dev_entry;

/// نقطة دخول افتراضية = بيئة التطوير (لتسهيل flutter run اليومي بلا -t).
/// ⚠️ لا تُستخدم هذه للبناء النهائي أبداً — استخدم دوماً:
///   flutter build apk --release -t lib/main_prod.dart
Future<void> main() => dev_entry.main();
