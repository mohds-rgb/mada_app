import 'firestore_helpers.dart';

/// accountStatus: active / suspended / banned (بند 7، 13-ب).
enum AccountStatus { active, suspended, banned }

AccountStatus accountStatusFromString(String? v) {
  switch (v) {
    case 'suspended':
      return AccountStatus.suspended;
    case 'banned':
      return AccountStatus.banned;
    default:
      return AccountStatus.active;
  }
}

/// users — بند 7. الدور (role) لا يُحدَّث أبداً من العميل نفسه بعد الإنشاء
/// الأول (تُحميه Firestore Rules، بند 12) — التغيير فقط عبر admin_scripts.
class UserModel {
  const UserModel({
    required this.uid,
    required this.role,
    required this.email,
    this.phone,
    this.displayName,
    this.preferredLanguage = 'ar',
    this.isSimpleMode = false,
    this.loyaltyPoints = 0,
    this.referralCode,
    this.referredBy,
    this.accountStatus = AccountStatus.active,
    this.deviceFingerprint,
    this.createdAt,
  });

  final String uid;
  final String role; // customer / driver / officeAdmin / admin / owner
  final String email;
  final String? phone;
  final String? displayName;
  final String preferredLanguage; // ar / en
  final bool isSimpleMode; // وضع مبسّط لكبار السن/أقل دراية تقنية
  final int loyaltyPoints;
  final String? referralCode;
  final String? referredBy;
  final AccountStatus accountStatus;
  final String? deviceFingerprint; // بند 12-هـ / 13-د
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'role': role,
        'email': email,
        'phone': phone,
        'displayName': displayName,
        'preferredLanguage': preferredLanguage,
        'isSimpleMode': isSimpleMode,
        'loyaltyPoints': loyaltyPoints,
        'referralCode': referralCode,
        'referredBy': referredBy,
        'accountStatus': accountStatus.name,
        'deviceFingerprint': deviceFingerprint,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
        uid: uid,
        role: map['role'] as String? ?? 'customer',
        email: map['email'] as String? ?? '',
        phone: map['phone'] as String?,
        displayName: map['displayName'] as String?,
        preferredLanguage: map['preferredLanguage'] as String? ?? 'ar',
        isSimpleMode: map['isSimpleMode'] as bool? ?? false,
        loyaltyPoints: (map['loyaltyPoints'] as num?)?.toInt() ?? 0,
        referralCode: map['referralCode'] as String?,
        referredBy: map['referredBy'] as String?,
        accountStatus: accountStatusFromString(map['accountStatus'] as String?),
        deviceFingerprint: map['deviceFingerprint'] as String?,
        createdAt: tsToDate(map['createdAt']),
      );
}
