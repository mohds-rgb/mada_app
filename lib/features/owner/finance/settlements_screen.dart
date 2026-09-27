import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../core/theme/app_colors.dart';

/// تسوية ديون العمولة مع السائقين (بند 7، 10، 8-المرحلة 4-ج).
/// ⚠️ الحماية المالية تعتمد حصراً على Firestore Rules (لا Cloud Functions
/// على Spark، بند 6-8) — لذا هذا الإجراء **مسموح فقط لـowner/admin عبر
/// Custom Claims**، ويُسجَّل بمعاملة واحدة (Transaction) مع auditLogs.
class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  Future<void> _settle(BuildContext context, String driverId, double debt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد التسوية'),
        content: Text('سيتم تصفير دَين السائق البالغ ${debt.abs().toStringAsFixed(0)} ل.س وتسجيله كتسوية مكتملة.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('تراجع')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد')),
        ],
      ),
    );
    if (confirmed != true) return;

    final ownerUid = FirebaseAuth.instance.currentUser!.uid;
    final walletRef = FirebaseFirestore.instance.collection(FirestoreCollections.wallets).doc(driverId);
    final driverRef = FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(driverId);
    final settlementRef = FirebaseFirestore.instance.collection(FirestoreCollections.commissionSettlements).doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.set(walletRef, {'balance': 0, 'updatedAt': FieldValue.serverTimestamp()});
      tx.update(driverRef, {'walletBalance': 0});
      tx.set(settlementRef, {
        'driverId': driverId,
        'amount': debt.abs(),
        'settledBy': ownerUid,
        'date': FieldValue.serverTimestamp(),
      });
    });

    await const AuditLogService().log(action: 'commissionSettled', targetId: driverId, details: {'amount': debt.abs()});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.drivers).where('walletBalance', isLessThan: 0).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد ديون مستحقة حالياً — كل السائقين مسوَّون'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final debt = (data['walletBalance'] as num?)?.toDouble() ?? 0;
            return Card(
              child: ListTile(
                title: Text(data['fullName'] as String? ?? '(بلا اسم)'),
                subtitle: Text('دَين مستحق: ${debt.abs().toStringAsFixed(0)} ل.س', style: const TextStyle(color: AppColors.error)),
                trailing: ElevatedButton(onPressed: () => _settle(context, docs[i].id, debt), child: const Text('تمت التسوية')),
              ),
            );
          },
        );
      },
    );
  }
}
