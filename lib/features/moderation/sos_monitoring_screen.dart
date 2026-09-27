import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/audit_log_service.dart';
import '../../core/theme/app_colors.dart';

/// متابعة حالات الطوارئ (SOS) — أولوية قصوى مطلقة (بند 22، 8-المرحلة 4-أ/4.5).
class SosMonitoringScreen extends StatelessWidget {
  const SosMonitoringScreen({super.key});

  Future<void> _acknowledge(String id) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.sosIncidents).doc(id).update({'status': 'acknowledged'});
    await const AuditLogService().log(action: 'sosAcknowledged', targetId: id);
  }

  Future<void> _resolve(String id) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.sosIncidents).doc(id).update({'status': 'resolved'});
    await const AuditLogService().log(action: 'sosResolved', targetId: id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestoreCollections.sosIncidents)
          .where('status', whereIn: ['open', 'acknowledged'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد حالات طوارئ مفتوحة حالياً'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final status = data['status'] as String? ?? 'open';
            final lat = (data['lat'] as num?)?.toDouble();
            final lng = (data['lng'] as num?)?.toDouble();

            return Card(
              color: status == 'open' ? AppColors.sosRed.withValues(alpha: 0.1) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sos_rounded, color: status == 'open' ? AppColors.sosRed : AppColors.warning),
                        const SizedBox(width: 8),
                        Text(status == 'open' ? 'مفتوحة — تحتاج استجابة فورية' : 'قيد المتابعة', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    if (lat != null && lng != null) ...[
                      const SizedBox(height: 6),
                      Text('الموقع: $lat, $lng'),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (status == 'open')
                          Expanded(child: OutlinedButton(onPressed: () => _acknowledge(docs[i].id), child: const Text('جارٍ التعامل معها'))),
                        if (status == 'open') const SizedBox(width: 8),
                        Expanded(child: ElevatedButton(onPressed: () => _resolve(docs[i].id), child: const Text('تم الحل'))),
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
}
