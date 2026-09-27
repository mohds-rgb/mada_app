import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';

/// واجهة المصادقة القابلة للتبديل (بند 5). التبديل يتم بسطر إعداد واحد
/// (تغيير التنفيذ المُمرَّر عند التهيئة) دون لمس بقية الكود.
abstract class OtpProvider {
  /// يرسل رابط الدخول إلى البريد الإلكتروني.
  Future<void> sendLoginLink({required String identifier});

  /// هل هذا الرابط (المُلتقَط من البريد يدوياً أو عبر Deep Link) رابط دخول صالح؟
  bool isValidLoginLink(String link);

  /// يكمل عملية الدخول بعد الحصول على الرابط الكامل.
  Future<UserCredential> completeSignIn({required String identifier, required String link});

  bool get requiresPaymentCard;
}

/// ============ النشط الآن — بلا أي بطاقة بنكية (بند 5) ============
/// Firebase Email Link Sign-in — مجاني بالكامل على باقة Spark.
///
/// ⚠️ قيد مؤقت موثَّق (PROJECT_STATE.md): خدمة Firebase Dynamic Links
/// أُغلقت للمشاريع الجديدة، لذا لا يمكن الاعتماد عليها لفتح التطبيق تلقائياً
/// عند نقر رابط البريد على الجوال. الحل الحالي العملي: بعد إرسال الرابط،
/// يفتح المستخدم بريده وينسخ الرابط كاملاً ويلصقه بشاشة تسجيل الدخول
/// (حقل "الصق رابط الدخول") — يعمل فوراً بلا أي إعداد إضافي. تحسين لاحق
/// اختياري: Firebase Hosting + Android App Links للفتح التلقائي بلمسة واحدة.
class EmailOtpProvider implements OtpProvider {
  const EmailOtpProvider();

  @override
  bool get requiresPaymentCard => false;

  ActionCodeSettings get _actionCodeSettings => ActionCodeSettings(
        url: 'https://${AppConfig.instance.isDev ? 'mada-dev-5ca8e' : 'mada-prod'}.firebaseapp.com/finishSignIn',
        handleCodeInApp: true,
      );

  @override
  Future<void> sendLoginLink({required String identifier}) async {
    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: identifier,
      actionCodeSettings: _actionCodeSettings,
    );
  }

  @override
  bool isValidLoginLink(String link) {
    return FirebaseAuth.instance.isSignInWithEmailLink(link);
  }

  @override
  Future<UserCredential> completeSignIn({required String identifier, required String link}) {
    return FirebaseAuth.instance.signInWithEmailLink(email: identifier, emailLink: link);
  }
}

/// ============ Stub جاهز، معطَّل — يتطلب بطاقة بنكية وربط Blaze ============
class FirebaseOtpProvider implements OtpProvider {
  const FirebaseOtpProvider();

  @override
  bool get requiresPaymentCard => true;

  @override
  Future<void> sendLoginLink({required String identifier}) =>
      throw UnsupportedError('FirebaseOtpProvider (SMS) معطَّل حالياً — يتطلب باقة Blaze (بند 5، 15، 17)');

  @override
  bool isValidLoginLink(String link) => false;

  @override
  Future<UserCredential> completeSignIn({required String identifier, required String link}) =>
      throw UnsupportedError('FirebaseOtpProvider معطَّل حالياً — يتطلب باقة Blaze (بند 5، 15، 17)');
}

/// ============ Stub مرجعي، معطَّل ============
class WhatsAppOtpProvider implements OtpProvider {
  const WhatsAppOtpProvider();

  @override
  bool get requiresPaymentCard => true;

  @override
  Future<void> sendLoginLink({required String identifier}) =>
      throw UnsupportedError('WhatsAppOtpProvider مرجعي فقط — غير مُفعَّل');

  @override
  bool isValidLoginLink(String link) => false;

  @override
  Future<UserCredential> completeSignIn({required String identifier, required String link}) =>
      throw UnsupportedError('WhatsAppOtpProvider مرجعي فقط — غير مُفعَّل');
}

/// نقطة تبديل المزوّد النشط — سطر واحد فقط (بند 5، 15، 17).
const OtpProvider activeOtpProvider = EmailOtpProvider();
