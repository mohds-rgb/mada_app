// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MADA';

  @override
  String get appTagline => 'Every Destination Closer';

  @override
  String get ownershipNotice => '© M&M TECH — All Rights Reserved';

  @override
  String get roleSelectionTitle => 'Choose Your Role';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get roleDriver => 'Driver';

  @override
  String get roleOffice => 'Rental Office';

  @override
  String get roleCustomerDesc =>
      'Request a ride, rent a car, or send a package';

  @override
  String get roleDriverDesc =>
      'Join as a driver and provide rides and deliveries';

  @override
  String get roleOfficeDesc => 'Manage your fleet and office bookings';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get emailHint => 'Email address';

  @override
  String get sendLoginLink => 'Send Login Link';

  @override
  String get termsTitle => 'Terms & Conditions and Privacy Policy';

  @override
  String get termsAgree =>
      'I agree to the Terms & Conditions and Privacy Policy';

  @override
  String get continueLabel => 'Continue';

  @override
  String get pendingReviewTitle => 'Under Review';

  @override
  String get pendingReviewBody =>
      'Your application is under review by management, we\'ll notify you once approved';

  @override
  String get loading => 'Loading...';
}
