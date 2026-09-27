import 'package:cloud_firestore/cloud_firestore.dart';

/// adminSettings — بند 7. مستند وحيد بمعرّف FirestoreCollections.adminSettingsDocId.
/// القيم الافتراضية هنا مطابقة لحسابات بند 8-المرحلة 0.5 المُصحَّحة.
class AdminSettingsModel {
  const AdminSettingsModel({
    this.commissionPercentage = 15,
    this.deliveryBaseFare = 3000,
    this.searchRadiusKm = 5,
    this.callCenterNumbers = const ['+963-11-000-0000'],
    this.minSupportedVersion = '1.0.0',
    this.baseFare = 2000,
    this.perKmRate = 800,
    this.perMinRate = 100,
    this.surgeMultiplier = 1.0,
    this.maxSurgeMultiplier = 1.5, // متحفظ لسوق درعا الحساس للسعر (بند 14)
    this.surgeHours = const [],
    this.cancellationGracePeriodMin = 3,
    this.noShowFee = 2000,
    this.driverSearchTimeoutSec = 30,
    this.driverSearchRadiusKm = 5,
    this.driverSearchExpansionSteps = const [5, 8, 12],
    this.subscriptionMonthlyFee = 50000,
    this.subscriptionGracePeriodDays = 7,
    this.lateFeePerHour = 5000,
    this.depositPercentage = 20,
    this.locationUpdateIntervalSec = 20, // بند 8-0.5 — الحساب المُصحَّح
    this.emergencyModeIntervalSec = 30,
    this.emergencyModeActive = false,
    this.referralMonthlyCap = 10, // بند 13-د
    this.maxUnsettledDebt = 100000, // بند 10، 14 — قيمة متحفظة أولية
    this.economyMultiplier = 1.0,
    this.comfortMultiplier = 1.3,
    this.premiumMultiplier = 1.6,
    this.isServiceEnabled = true, // بند 8-المرحلة 4-هـ: مفتاح تشغيل/إيقاف الخدمة كلياً
    this.announcement, // بند 8-المرحلة 4-هـ: إشعار جماعي (بديل بلا Cloud Functions — بانر داخل التطبيق)
    this.announcementUpdatedAt,
  });

  final double commissionPercentage;
  final double deliveryBaseFare;
  final double searchRadiusKm;
  final List<String> callCenterNumbers;
  final String minSupportedVersion; // بند 16 — Force Update
  final double baseFare;
  final double perKmRate;
  final double perMinRate;
  final double surgeMultiplier;
  final double maxSurgeMultiplier; // حد أقصى فعلي — بند 7، 14
  final List<String> surgeHours;
  final int cancellationGracePeriodMin;
  final double noShowFee;
  final int driverSearchTimeoutSec;
  final double driverSearchRadiusKm;
  final List<double> driverSearchExpansionSteps;
  final double subscriptionMonthlyFee;
  final int subscriptionGracePeriodDays;
  final double lateFeePerHour;
  final double depositPercentage;
  final int locationUpdateIntervalSec; // بند 8-0.5 (20 لا 10 — الحساب المُصحَّح)
  final int emergencyModeIntervalSec; // بند 17-أ — وضع الطوارئ
  final bool emergencyModeActive;
  final int referralMonthlyCap;
  final double maxUnsettledDebt; // بند 10، 14
  // معامِلات فئات المركبة (قرار موثَّق بالمرحلة 1 — قيم أولية معقولة، قابلة
  // للتعديل من لوحة المالك لاحقاً بالمرحلة 4، بند 21-هـ).
  final double economyMultiplier;
  final double comfortMultiplier;
  final double premiumMultiplier;
  final bool isServiceEnabled;
  final String? announcement;
  final DateTime? announcementUpdatedAt;

  Map<String, dynamic> toMap() => {
        'commissionPercentage': commissionPercentage,
        'deliveryBaseFare': deliveryBaseFare,
        'searchRadiusKm': searchRadiusKm,
        'callCenterNumbers': callCenterNumbers,
        'minSupportedVersion': minSupportedVersion,
        'baseFare': baseFare,
        'perKmRate': perKmRate,
        'perMinRate': perMinRate,
        'surgeMultiplier': surgeMultiplier,
        'maxSurgeMultiplier': maxSurgeMultiplier,
        'surgeHours': surgeHours,
        'cancellationGracePeriodMin': cancellationGracePeriodMin,
        'noShowFee': noShowFee,
        'driverSearchTimeoutSec': driverSearchTimeoutSec,
        'driverSearchRadiusKm': driverSearchRadiusKm,
        'driverSearchExpansionSteps': driverSearchExpansionSteps,
        'subscriptionMonthlyFee': subscriptionMonthlyFee,
        'subscriptionGracePeriodDays': subscriptionGracePeriodDays,
        'lateFeePerHour': lateFeePerHour,
        'depositPercentage': depositPercentage,
        'locationUpdateIntervalSec': locationUpdateIntervalSec,
        'emergencyModeIntervalSec': emergencyModeIntervalSec,
        'emergencyModeActive': emergencyModeActive,
        'referralMonthlyCap': referralMonthlyCap,
        'maxUnsettledDebt': maxUnsettledDebt,
        'economyMultiplier': economyMultiplier,
        'comfortMultiplier': comfortMultiplier,
        'premiumMultiplier': premiumMultiplier,
        'isServiceEnabled': isServiceEnabled,
        'announcement': announcement,
        'announcementUpdatedAt': announcementUpdatedAt == null ? null : Timestamp.fromDate(announcementUpdatedAt!),
      };

  factory AdminSettingsModel.fromMap(Map<String, dynamic> map) => AdminSettingsModel(
        commissionPercentage: (map['commissionPercentage'] as num?)?.toDouble() ?? 15,
        deliveryBaseFare: (map['deliveryBaseFare'] as num?)?.toDouble() ?? 3000,
        searchRadiusKm: (map['searchRadiusKm'] as num?)?.toDouble() ?? 5,
        callCenterNumbers: List<String>.from(map['callCenterNumbers'] as List? ?? const []),
        minSupportedVersion: map['minSupportedVersion'] as String? ?? '1.0.0',
        baseFare: (map['baseFare'] as num?)?.toDouble() ?? 2000,
        perKmRate: (map['perKmRate'] as num?)?.toDouble() ?? 800,
        perMinRate: (map['perMinRate'] as num?)?.toDouble() ?? 100,
        surgeMultiplier: (map['surgeMultiplier'] as num?)?.toDouble() ?? 1.0,
        maxSurgeMultiplier: (map['maxSurgeMultiplier'] as num?)?.toDouble() ?? 1.5,
        surgeHours: List<String>.from(map['surgeHours'] as List? ?? const []),
        cancellationGracePeriodMin: (map['cancellationGracePeriodMin'] as num?)?.toInt() ?? 3,
        noShowFee: (map['noShowFee'] as num?)?.toDouble() ?? 2000,
        driverSearchTimeoutSec: (map['driverSearchTimeoutSec'] as num?)?.toInt() ?? 30,
        driverSearchRadiusKm: (map['driverSearchRadiusKm'] as num?)?.toDouble() ?? 5,
        driverSearchExpansionSteps:
            (map['driverSearchExpansionSteps'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? const [5, 8, 12],
        subscriptionMonthlyFee: (map['subscriptionMonthlyFee'] as num?)?.toDouble() ?? 50000,
        subscriptionGracePeriodDays: (map['subscriptionGracePeriodDays'] as num?)?.toInt() ?? 7,
        lateFeePerHour: (map['lateFeePerHour'] as num?)?.toDouble() ?? 5000,
        depositPercentage: (map['depositPercentage'] as num?)?.toDouble() ?? 20,
        locationUpdateIntervalSec: (map['locationUpdateIntervalSec'] as num?)?.toInt() ?? 20,
        emergencyModeIntervalSec: (map['emergencyModeIntervalSec'] as num?)?.toInt() ?? 30,
        emergencyModeActive: map['emergencyModeActive'] as bool? ?? false,
        referralMonthlyCap: (map['referralMonthlyCap'] as num?)?.toInt() ?? 10,
        maxUnsettledDebt: (map['maxUnsettledDebt'] as num?)?.toDouble() ?? 100000,
        economyMultiplier: (map['economyMultiplier'] as num?)?.toDouble() ?? 1.0,
        comfortMultiplier: (map['comfortMultiplier'] as num?)?.toDouble() ?? 1.3,
        premiumMultiplier: (map['premiumMultiplier'] as num?)?.toDouble() ?? 1.6,
        isServiceEnabled: map['isServiceEnabled'] as bool? ?? true,
        announcement: map['announcement'] as String?,
        announcementUpdatedAt: (map['announcementUpdatedAt'] as Timestamp?)?.toDate(),
      );
}
