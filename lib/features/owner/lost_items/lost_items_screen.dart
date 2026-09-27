import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';

/// إدارة المفقودات — مراجعة البلاغات وإغلاقها عند التسليم (بند 8-المرحلة 4-ح).
/// ⚠️ "التواصل بين الطرفين" مبسَّط حالياً لملاحظة نصية على البلاغ (لا دردشة
/// حيّة بعد — نفس القيد الموثَّق بالمرحلة 2 حول غياب الدردشة).
class LostItemsScreen extends StatelessWidget {
  const LostItemsScreen({super.key});

  Future<void> _updateStatus(String id, String status) {
    return FirebaseFirestore.instance.collection(FirestoreCollections.lostItems).doc(id).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.lostItems).orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد بلاغات مفقودات'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final status = data['status'] as String? ?? 'open';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['itemDescription'] as String? ?? '', style: Theme.of(context).textTheme.titleMedium),
                    Text('رحلة: ${data['tripId'] ?? '—'}'),
                    Text(_statusLabel(status), style: TextStyle(color: status == 'closed' ? AppColors.success : AppColors.warning)),
                    if (status != 'closed') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (status == 'open')
                            Expanded(child: OutlinedButton(onPressed: () => _updateStatus(docs[i].id, 'found'), child: const Text('تم العثور عليه'))),
                          if (status == 'open') const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: () => _updateStatus(docs[i].id, 'closed'), child: const Text('إغلاق (تم التسليم)'))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'found':
        return 'تم العثور عليه — بانتظار التسليم';
      case 'closed':
        return 'تم التسليم — مغلَق';
      default:
        return 'مفتوح';
    }
  }
}
