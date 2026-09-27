import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'مدى'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'كل وجهة أقرب'**
  String get appTagline;

  /// No description provided for @ownershipNotice.
  ///
  /// In ar, this message translates to:
  /// **'© M&M TECH — جميع الحقوق محفوظة'**
  String get ownershipNotice;

  /// No description provided for @roleSelectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر دورك'**
  String get roleSelectionTitle;

  /// No description provided for @roleCustomer.
  ///
  /// In ar, this message translates to:
  /// **'عميل'**
  String get roleCustomer;

  /// No description provided for @roleDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get roleDriver;

  /// No description provided for @roleOffice.
  ///
  /// In ar, this message translates to:
  /// **'مكتب تأجير'**
  String get roleOffice;

  /// No description provided for @roleCustomerDesc.
  ///
  /// In ar, this message translates to:
  /// **'اطلب رحلة، استأجر سيارة، أو أرسل طرداً'**
  String get roleCustomerDesc;

  /// No description provided for @roleDriverDesc.
  ///
  /// In ar, this message translates to:
  /// **'انضم كسائق ووفّر رحلات وتوصيل'**
  String get roleDriverDesc;

  /// No description provided for @roleOfficeDesc.
  ///
  /// In ar, this message translates to:
  /// **'أدر أسطول سياراتك وحجوزات مكتبك'**
  String get roleOfficeDesc;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @emailHint.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailHint;

  /// No description provided for @sendLoginLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط الدخول'**
  String get sendLoginLink;

  /// No description provided for @termsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام وسياسة الخصوصية'**
  String get termsTitle;

  /// No description provided for @termsAgree.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على الشروط والأحكام وسياسة الخصوصية'**
  String get termsAgree;

  /// No description provided for @continueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueLabel;

  /// No description provided for @pendingReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get pendingReviewTitle;

  /// No description provided for @pendingReviewBody.
  ///
  /// In ar, this message translates to:
  /// **'طلبك قيد المراجعة من قبل الإدارة، سنُعلمك فور الاعتماد'**
  String get pendingReviewBody;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
