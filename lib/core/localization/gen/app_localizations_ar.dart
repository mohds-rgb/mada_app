// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مدى';

  @override
  String get appTagline => 'كل وجهة أقرب';

  @override
  String get ownershipNotice => '© M&M TECH — جميع الحقوق محفوظة';

  @override
  String get roleSelectionTitle => 'اختر دورك';

  @override
  String get roleCustomer => 'عميل';

  @override
  String get roleDriver => 'سائق';

  @override
  String get roleOffice => 'مكتب تأجير';

  @override
  String get roleCustomerDesc => 'اطلب رحلة، استأجر سيارة، أو أرسل طرداً';

  @override
  String get roleDriverDesc => 'انضم كسائق ووفّر رحلات وتوصيل';

  @override
  String get roleOfficeDesc => 'أدر أسطول سياراتك وحجوزات مكتبك';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String get sendLoginLink => 'إرسال رابط الدخول';

  @override
  String get termsTitle => 'الشروط والأحكام وسياسة الخصوصية';

  @override
  String get termsAgree => 'أوافق على الشروط والأحكام وسياسة الخصوصية';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get pendingReviewTitle => 'قيد المراجعة';

  @override
  String get pendingReviewBody =>
      'طلبك قيد المراجعة من قبل الإدارة، سنُعلمك فور الاعتماد';

  @override
  String get loading => 'جارٍ التحميل...';
}
