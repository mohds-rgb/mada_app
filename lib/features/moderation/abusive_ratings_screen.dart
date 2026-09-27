import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';

/// مراجعة التقييمات المنخفضة/المسيئة المحتملة (بند 8-المرحلة 4-4.5).
/// ⚠️ للعرض فقط — التقييمات غير قابلة للتعديل أو الحذف مطلقاً بعد الإرسال
/// (Firestore Rules، بند 7) حفاظاً على مصداقية النظام؛ المراجعة هنا تفيد
/// فقط في اتخاذ قرار بلاغ/تحذير منفصل بحق كاتب التقييم إن أسيء استخدامه.
class AbusiveRatingsScreen extends StatelessWidget {
  const AbusiveRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.ratings).where('stars', isLessThanOrEqualTo: 2).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد تقييمات منخفضة تحتاج مراجعة'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            return Card(
              child: ListTile(
                title: Row(children: List.generate(5, (s) => Icon(s < (data['stars'] as num).toInt() ? Icons.star : Icons.star_border, size: 16))),
                subtitle: Text(data['note'] as String? ?? '(بلا ملاحظة)'),
              ),
            );
          },
        );
      },
    );
  }
}
