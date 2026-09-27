import 'firestore_helpers.dart';

/// subscriptionStatus: active / expired / gracePeriod (بند 7، 14).
enum SubscriptionStatus { active, expired, gracePeriod }

SubscriptionStatus subStatusFromString(String? v) {
  switch (v) {
    case 'expired':
      return SubscriptionStatus.expired;
    case 'gracePeriod':
      return SubscriptionStatus.gracePeriod;
    default:
      return SubscriptionStatus.active;
  }
}

/// approvalStatus: اعتماد المكتب نفسه من المالك (منفصل عن حالة الاشتراك
/// المالية) — بند 3-أ-4: "نفس مبدأ قيد المراجعة" عند التسجيل الذاتي.
enum OfficeApprovalStatus { pending, approved, blocked }

OfficeApprovalStatus officeApprovalFromString(String? v) {
  switch (v) {
    case 'approved':
      return OfficeApprovalStatus.approved;
    case 'blocked':
      return OfficeApprovalStatus.blocked;
    default:
      return OfficeApprovalStatus.pending;
  }
}

/// offices — بند 7.
class OfficeModel {
  const OfficeModel({
    required this.officeId,
    required this.name,
    required this.ownerAdminUid,
    this.approvalStatus = OfficeApprovalStatus.pending,
    this.plan = 'standard',
    this.subscriptionStatus = SubscriptionStatus.active,
    this.expiryDate,
    this.paymentMethod = 'cash',
    this.gracePeriodEndDate,
    this.createdAt,
  });

  final String officeId;
  final String name;
  final String ownerAdminUid; // uid حساب officeAdmin المرتبط
  final OfficeApprovalStatus approvalStatus;
  final String plan;
  final SubscriptionStatus subscriptionStatus;
  final DateTime? expiryDate;
  final String paymentMethod; // cash / sham_cash
  final DateTime? gracePeriodEndDate;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'name': name,
        'ownerAdminUid': ownerAdminUid,
        'approvalStatus': approvalStatus.name,
        'plan': plan,
        'subscriptionStatus': subscriptionStatus.name,
        'expiryDate': dateToTs(expiryDate),
        'paymentMethod': paymentMethod,
        'gracePeriodEndDate': dateToTs(gracePeriodEndDate),
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory OfficeModel.fromMap(String officeId, Map<String, dynamic> map) => OfficeModel(
        officeId: officeId,
        name: map['name'] as String? ?? '',
        ownerAdminUid: map['ownerAdminUid'] as String? ?? '',
        approvalStatus: officeApprovalFromString(map['approvalStatus'] as String?),
        plan: map['plan'] as String? ?? 'standard',
        subscriptionStatus: subStatusFromString(map['subscriptionStatus'] as String?),
        expiryDate: tsToDate(map['expiryDate']),
        paymentMethod: map['paymentMethod'] as String? ?? 'cash',
        gracePeriodEndDate: tsToDate(map['gracePeriodEndDate']),
        createdAt: tsToDate(map['createdAt']),
      );
}

/// subscriptionPayments — بند 7، 14.
class SubscriptionPaymentModel {
  const SubscriptionPaymentModel({
    required this.id,
    required this.officeId,
    required this.amount,
    required this.method,
    required this.recordedBy,
    this.date,
  });

  final String id;
  final String officeId;
  final double amount;
  final String method; // cash / sham_cash
  final String recordedBy; // uid الأدمن الذي سجّل الدفعة
  final DateTime? date;

  Map<String, dynamic> toMap() => {
        'officeId': officeId,
        'amount': amount,
        'method': method,
        'recordedBy': recordedBy,
        'date': dateToTs(date ?? DateTime.now()),
      };

  factory SubscriptionPaymentModel.fromMap(String id, Map<String, dynamic> map) => SubscriptionPaymentModel(
        id: id,
        officeId: map['officeId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        method: map['method'] as String? ?? 'cash',
        recordedBy: map['recordedBy'] as String? ?? '',
        date: tsToDate(map['date']),
      );
}
