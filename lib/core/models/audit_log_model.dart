import 'firestore_helpers.dart';

/// auditLogs — بند 7، 13-ج. append-only، غير قابل للحذف أو التعديل أبداً
/// (مفروض عبر Firestore Rules — بند 12)، يحمي المالك من أي نزاع إداري لاحق.
class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.actorUid,
    required this.action,
    this.targetId,
    this.details,
    this.timestamp,
  });

  final String id;
  final String actorUid; // من نفّذ الإجراء (owner/admin عادة)
  final String action; // ماذا: banUser / resolveReport / changeCommission ...
  final String? targetId; // على ماذا طُبِّق الإجراء
  final Map<String, dynamic>? details;
  final DateTime? timestamp;

  Map<String, dynamic> toMap() => {
        'actorUid': actorUid,
        'action': action,
        'targetId': targetId,
        'details': details,
        'timestamp': dateToTs(timestamp ?? DateTime.now()),
      };

  factory AuditLogModel.fromMap(String id, Map<String, dynamic> map) => AuditLogModel(
        id: id,
        actorUid: map['actorUid'] as String? ?? '',
        action: map['action'] as String? ?? '',
        targetId: map['targetId'] as String?,
        details: map['details'] as Map<String, dynamic>?,
        timestamp: tsToDate(map['timestamp']),
      );
}
