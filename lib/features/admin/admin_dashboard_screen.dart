import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/theme/app_colors.dart';

/// لوحة قيادة الأدمن التشغيلي — تشغيلية بحتة، **بلا أي رقم مالي**
/// (إيرادات/عمولات) تماشياً مع بند 8-المرحلة 4.5 ("دون الصلاحيات المالية").
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestoreCollections.sosIncidents).where('status', isEqualTo: 'open').snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length ?? 0;
            if (count == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.sosRed, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.sos_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text('$count حالة طوارئ (SOS) مفتوحة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            );
          },
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestoreCollections.drivers).where('status', isEqualTo: 'pending').snapshots(),
          builder: (context, driverSnap) {
            final pending = driverSnap.data?.docs.length ?? 0;
            if (pending == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
              child: Text('$pending سائق بانتظار اعتماد الوثائق', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
        Text('اليوم', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(FirestoreCollections.rideRequests)
              .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            final completed = docs.where((d) => d.data()['status'] == 'completed').length;
            final cancelled = docs.where((d) => d.data()['status'] == 'cancelled').length;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                _KpiCard(label: 'رحلات اليوم', value: '${docs.length}'),
                _KpiCard(label: 'مكتملة', value: '$completed'),
                _KpiCard(label: 'ملغاة', value: '$cancelled'),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.turquoise)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
