import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';

/// لوحة القيادة — مؤشرات حيّة + تنبيهات ذات أولوية (بند 8-المرحلة 4-أ).
/// SOS يظهر أولاً دوماً فوق أي تنبيه آخر (بند 22: أولوية قصوى مطلقة).
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🆘 تنبيه SOS — أولوية قصوى مطلقة فوق كل شيء آخر (بند 22).
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
                  Expanded(
                    child: Text('$count حالة طوارئ (SOS) مفتوحة — تحتاج تدخلاً فورياً', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),

        // تنبيهات بانتظار المراجعة
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestoreCollections.drivers).where('status', isEqualTo: 'pending').snapshots(),
          builder: (context, driverSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection(FirestoreCollections.offices).where('approvalStatus', isEqualTo: 'pending').snapshots(),
              builder: (context, officeSnap) {
                final pendingDrivers = driverSnap.data?.docs.length ?? 0;
                final pendingOffices = officeSnap.data?.docs.length ?? 0;
                if (pendingDrivers == 0 && pendingOffices == 0) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: Text(
                    '${pendingDrivers > 0 ? '$pendingDrivers سائق' : ''}'
                    '${pendingDrivers > 0 && pendingOffices > 0 ? ' و' : ''}'
                    '${pendingOffices > 0 ? '$pendingOffices مكتب' : ''}'
                    ' بانتظار المراجعة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
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
            final completed = docs.where((d) => d.data()['status'] == 'completed').toList();
            final cancelled = docs.where((d) => d.data()['status'] == 'cancelled').length;
            final revenue = completed.fold<double>(0, (sum, d) => sum + ((d.data()['fare'] as num?)?.toDouble() ?? 0));

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _KpiCard(label: 'رحلات اليوم', value: '${docs.length}'),
                _KpiCard(label: 'رحلات مكتملة', value: '${completed.length}'),
                _KpiCard(label: 'رحلات ملغاة', value: '$cancelled'),
                _KpiCard(label: 'إيرادات اليوم', value: '${revenue.toStringAsFixed(0)} ل.س'),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.turquoise)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
