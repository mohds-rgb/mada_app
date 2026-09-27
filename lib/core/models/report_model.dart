import 'firestore_helpers.dart';

/// status دورة حياة البلاغ الموحَّدة (بند 13-ب).
enum ReportStatus { open, underReview, resolved, dismissed }

ReportStatus reportStatusFromString(String? v) {
  switch (v) {
    case 'underReview':
      return ReportStatus.underReview;
    case 'resolved':
      return ReportStatus.resolved;
    case 'dismissed':
      return ReportStatus.dismissed;
    default:
      return ReportStatus.open;
  }
}

/// reports — بند 7، 13.
class ReportModel {
  const ReportModel({
    required this.id,
    required this.type,
    required this.reporterId,
    required this.reportedUserId,
    required this.description,
    this.evidenceUrls = const [],
    this.status = ReportStatus.open,
    this.decision,
    this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
  });

  final String id;
  final String type; // driverAgainstCustomer / customerAgainstDriver / vehicleDamageDispute / sos / other
  final String reporterId;
  final String reportedUserId;
  final String description;
  final List<String> evidenceUrls;
  final ReportStatus status;
  final String? decision; // warning / suspend / ban / refund
  final String? resolvedBy; // owner فقط للقرار النهائي (بند 13-ب-3)
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'type': type,
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'description': description,
        'evidenceUrls': evidenceUrls,
        'status': status.name,
        'decision': decision,
        'resolvedBy': resolvedBy,
        'resolvedAt': dateToTs(resolvedAt),
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory ReportModel.fromMap(String id, Map<String, dynamic> map) => ReportModel(
        id: id,
        type: map['type'] as String? ?? 'other',
        reporterId: map['reporterId'] as String? ?? '',
        reportedUserId: map['reportedUserId'] as String? ?? '',
        description: map['description'] as String? ?? '',
        evidenceUrls: List<String>.from(map['evidenceUrls'] as List? ?? const []),
        status: reportStatusFromString(map['status'] as String?),
        decision: map['decision'] as String?,
        resolvedBy: map['resolvedBy'] as String?,
        resolvedAt: tsToDate(map['resolvedAt']),
        createdAt: tsToDate(map['createdAt']),
      );
}
