/// أسماء مجموعات Firestore المركزية (بند 7) — يُستخدم هذا الملف بكل مكان
/// بدل كتابة الأسماء النصية مباشرة، لتفادي أخطاء الطباعة عبر المشروع.
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String drivers = 'drivers';
  static const String offices = 'offices';
  static const String subscriptionPayments = 'subscriptionPayments';
  static const String vehicles = 'vehicles';
  static const String rideRequests = 'rideRequests';
  static const String deliveryRequests = 'deliveryRequests';
  static const String rentalBookings = 'rentalBookings';
  static const String wallets = 'wallets';
  static const String commissionSettlements = 'commissionSettlements';
  static const String ratings = 'ratings';
  static const String reports = 'reports';
  static const String supportTickets = 'supportTickets';
  static const String promoCodes = 'promoCodes';
  static const String sosIncidents = 'sosIncidents';
  static const String trustedContacts = 'trustedContacts';
  static const String auditLogs = 'auditLogs';
  static const String adminSettings = 'adminSettings';
  static const String vehicleLocations = 'vehicleLocations';
  static const String loyaltyTransactions = 'loyaltyTransactions';
  static const String referralRedemptions = 'referralRedemptions';
  static const String lostItems = 'lostItems';
  static const String businessContracts = 'businessContracts';
  static const String bannedDevices = 'bannedDevices';

  /// مستند إعدادات المنصة الوحيد ضمن adminSettings (بند 7).
  static const String adminSettingsDocId = 'global';
}
