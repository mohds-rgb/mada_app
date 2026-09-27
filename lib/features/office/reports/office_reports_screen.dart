import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';

/// تقارير مبسّطة للمكتب: عدد الحجوزات والإيرادات المكتملة (بند 8-المرحلة 3).
/// ⚠️ قرار تبسيط موثَّق: تجميع على جهاز العميل (client-side) مناسب لحجم
/// MVP الحالي — تقارير أثقل (تصدير CSV/PDF، تحليل الأعلى طلباً) مؤجَّلة
/// للوحة المالك (المرحلة 4) حيث الحجم الكلي أكبر ويستدعي تجميعاً خادمياً.
class OfficeReportsScreen extends StatelessWidget {
  const OfficeReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).where('officeId', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        final completed = docs.where((d) => d.data()['status'] == 'completed').toList();
        final active = docs.where((d) => d.data()['status'] == 'active').toList();
        final totalRevenue = completed.fold<double>(0, (sum, d) => sum + ((d.data()['total'] as num?)?.toDouble() ?? 0));
        final totalLateFees = completed.fold<double>(0, (sum, d) => sum + ((d.data()['lateFee'] as num?)?.toDouble() ?? 0));

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _StatCard(label: 'إجمالي الحجوزات', value: '${docs.length}'),
            _StatCard(label: 'حجوزات نشطة حالياً', value: '${active.length}'),
            _StatCard(label: 'حجوزات مكتملة', value: '${completed.length}'),
            _StatCard(label: 'إجمالي الإيرادات (مكتمل)', value: '${totalRevenue.toStringAsFixed(0)} ل.س'),
            if (totalLateFees > 0) _StatCard(label: 'إجمالي غرامات التأخير', value: '${totalLateFees.toStringAsFixed(0)} ل.س'),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(title: Text(label), trailing: Text(value, style: Theme.of(context).textTheme.titleLarge)),
    );
  }
}
