import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/repositories/admin_settings_repository.dart';

/// تقرير أرباح المنصة الشامل (بند 8-المرحلة 4-ج): عمولات الرحلات المكتملة
/// + اشتراكات المكاتب، مجمَّعة حسب طريقة الدفع.
/// ⚠️ تجميع على جهاز العميل (client-side) — مناسب لحجم MVP الحالي؛ تقرير
/// خادمي مُحسَّن للأحجام الكبيرة مؤجَّل (يتطلب Cloud Functions للتجميع
/// الدوري بدل قراءة كل المستندات في كل مرة).
class PlatformProfitScreen extends StatelessWidget {
  const PlatformProfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: const AdminSettingsRepository().fetch().then((s) => s.commissionPercentage),
      builder: (context, commissionSnap) {
        final commissionPct = commissionSnap.data ?? 15;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).where('status', isEqualTo: 'completed').snapshots(),
          builder: (context, rideSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection(FirestoreCollections.subscriptionPayments).snapshots(),
              builder: (context, subSnap) {
                final rideDocs = rideSnap.data?.docs ?? [];
                final totalFares = rideDocs.fold<double>(0, (sum, d) => sum + ((d.data()['fare'] as num?)?.toDouble() ?? 0));
                final ridesCommission = totalFares * commissionPct / 100;
                final cashRides = rideDocs.where((d) => d.data()['paymentMethod'] == 'cash').length;
                final shamCashRides = rideDocs.where((d) => d.data()['paymentMethod'] == 'sham_cash').length;

                final subDocs = subSnap.data?.docs ?? [];
                final subscriptionRevenue = subDocs.fold<double>(0, (sum, d) => sum + ((d.data()['amount'] as num?)?.toDouble() ?? 0));

                final totalProfit = ridesCommission + subscriptionRevenue;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _StatRow(label: 'إجمالي عمولة الرحلات ($commissionPct%)', value: '${ridesCommission.toStringAsFixed(0)} ل.س'),
                    _StatRow(label: 'إيرادات اشتراكات المكاتب', value: '${subscriptionRevenue.toStringAsFixed(0)} ل.س'),
                    const Divider(height: 32),
                    _StatRow(label: 'إجمالي أرباح المنصة', value: '${totalProfit.toStringAsFixed(0)} ل.س', highlight: true),
                    const Divider(height: 32),
                    _StatRow(label: 'رحلات مدفوعة نقداً', value: '$cashRides'),
                    _StatRow(label: 'رحلات مدفوعة Sham Cash', value: '$shamCashRides'),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: highlight
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
