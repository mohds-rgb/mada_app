import 'firestore_helpers.dart';

/// status: pending (قيد المراجعة) / approved / blocked (بند 3-أ، 7).
enum DriverStatus { pending, approved, blocked }

DriverStatus driverStatusFromString(String? v) {
  switch (v) {
    case 'approved':
      return DriverStatus.approved;
    case 'blocked':
      return DriverStatus.blocked;
    default:
      return DriverStatus.pending;
  }
}

/// drivers — بند 7. walletBalance سالب = دَين مستحق على السائق (بند 10).
/// هذا الحقل محمي بالكامل عبر Firestore Rules — لا يكتبه السائق مباشرة أبداً
/// (استثناء مؤقت موثَّق، بند 6-8، 12؛ الترقية لاحقاً عبر Cloud Functions).
class DriverModel {
  const DriverModel({
    required this.uid,
    required this.fullName,
    required this.licenseNumber,
    required this.licensePhotoUrl,
    required this.vehicleType,
    required this.vehiclePlate,
    this.status = DriverStatus.pending,
    this.walletBalance = 0,
    this.isFemale = false,
    this.selfieCheckStatus = 'notRequired',
    this.rating = 5.0,
    this.officeId,
    this.createdAt,
  });

  final String uid;
  final String fullName;
  final String licenseNumber;
  final String licensePhotoUrl; // رابط Cloudinary
  final String vehicleType;
  final String vehiclePlate;
  final DriverStatus status;
  final double walletBalance; // سالب = دَين مستحق
  final bool isFemale; // لفلتر "سائقة فقط" الاختياري (بند 8، المرحلة 1)
  final String selfieCheckStatus; // notRequired / pending / verified / failed
  final double rating;
  final String? officeId; // إن كان مرتبطاً بمكتب تأجير
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'licenseNumber': licenseNumber,
        'licensePhotoUrl': licensePhotoUrl,
        'vehicleType': vehicleType,
        'vehiclePlate': vehiclePlate,
        'status': status.name,
        'walletBalance': walletBalance,
        'isFemale': isFemale,
        'selfieCheckStatus': selfieCheckStatus,
        'rating': rating,
        'officeId': officeId,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory DriverModel.fromMap(String uid, Map<String, dynamic> map) => DriverModel(
        uid: uid,
        fullName: map['fullName'] as String? ?? '',
        licenseNumber: map['licenseNumber'] as String? ?? '',
        licensePhotoUrl: map['licensePhotoUrl'] as String? ?? '',
        vehicleType: map['vehicleType'] as String? ?? '',
        vehiclePlate: map['vehiclePlate'] as String? ?? '',
        status: driverStatusFromString(map['status'] as String?),
        walletBalance: (map['walletBalance'] as num?)?.toDouble() ?? 0,
        isFemale: map['isFemale'] as bool? ?? false,
        selfieCheckStatus: map['selfieCheckStatus'] as String? ?? 'notRequired',
        rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
        officeId: map['officeId'] as String?,
        createdAt: tsToDate(map['createdAt']),
      );
}
