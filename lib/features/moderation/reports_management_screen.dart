import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/audit_log_service.dart';
import '../../core/theme/app_colors.dart';

/// مراجعة البلاغات — بند 13، 8-المرحلة 4-ط/4.5.
/// [isOwner] يتحكم بظهور "حظر نهائي" — حصراً لـowner (بند 13-ب-3، 8-4.5):
/// الأدمن التشغيلي يقدر فقط على "تحذير" و"حظر مؤقت" (Firestore Rules تفرض
/// نفس القيد مجدداً من جهة الخادم — هذا فقط لإخفاء الزر لتجربة أوضح).
class ReportsManagementScreen extends StatelessWidget {
  const ReportsManagementScreen({super.key, required this.isOwner});

  final bool isOwner;

  Future<void> _decide(BuildContext context, String reportId, String reportedUserId, String decision) async {
    // تحديث حالة المستخدم المبلَّغ عنه حسب القرار (بند 13-ب).
    if (decision == 'warning') {
      // تحذير فقط — لا تغيير على accountStatus، يُسجَّل بالسجل فقط.
    } else if (decision == 'suspend') {
      await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(reportedUserId).update({'accountStatus': 'suspended'});
    } else if (decision == 'ban') {
      await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(reportedUserId).update({'accountStatus': 'banned'});
      // ربط الحظر ببصمة الجهاز لمنع الالتفاف (بند 12-هـ، 13-د).
      final userDoc = await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(reportedUserId).get();
      final fingerprint = userDoc.data()?['deviceFingerprint'] as String?;
      if (fingerprint != null) {
        await FirebaseFirestore.instance.collection(FirestoreCollections.bannedDevices).doc(fingerprint).set({
          'reason': 'حظر نهائي — بلاغ $reportId',
          'bannedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).doc(reportId).update({
      'status': 'resolved',
      'decision': decision,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
    await const AuditLogService().log(action: 'reportResolved', targetId: reportId, details: {'decision': decision});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.reports).where('status', isEqualTo: 'open').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد بلاغات مفتوحة'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final reportedUserId = data['reportedUserId'] as String? ?? '';
            final evidenceUrls = List<String>.from(data['evidenceUrls'] as List? ?? const []);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeLabel(data['type'] as String? ?? 'other'), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(data['description'] as String? ?? ''),
                    if (evidenceUrls.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: evidenceUrls
                              .map((url) => Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 60, height: 60, fit: BoxFit.cover)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(onPressed: () => _decide(context, docs[i].id, reportedUserId, 'warning'), child: const Text('تحذير')),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.warning),
                          onPressed: () => _decide(context, docs[i].id, reportedUserId, 'suspend'),
                          child: const Text('حظر مؤقت'),
                        ),
                        if (isOwner)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            onPressed: () => _decide(context, docs[i].id, reportedUserId, 'ban'),
                            child: const Text('حظر نهائي'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'driverAgainstCustomer':
        return 'بلاغ سائق ضد عميل';
      case 'customerAgainstDriver':
        return 'بلاغ عميل ضد سائق';
      case 'vehicleDamageDispute':
        return 'نزاع حالة سيارة';
      case 'sos':
        return 'بلاغ طوارئ';
      default:
        return 'بلاغ آخر';
    }
  }
}
