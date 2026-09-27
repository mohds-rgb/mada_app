import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';

/// تسجيل كل إجراء إداري حسّاس بسجل غير قابل للحذف (بند 7، 13-ج، 21-و).
/// يُستدعى بعد كل عملية اعتماد/حظر/تعديل مالي من لوحة المالك.
class AuditLogService {
  const AuditLogService();

  Future<void> log({required String action, String? targetId, Map<String, dynamic>? details}) async {
    final actor = FirebaseAuth.instance.currentUser;
    if (actor == null) return;
    await FirebaseFirestore.instance.collection(FirestoreCollections.auditLogs).add({
      'actorUid': actor.uid,
      'action': action,
      'targetId': targetId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
