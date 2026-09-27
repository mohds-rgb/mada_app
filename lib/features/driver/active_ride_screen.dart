import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/commission_deduction_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/mada_primary_button.dart';

/// الرحلة النشطة الحالية للسائق — وصل/بدء/إنهاء (بند 8-المرحلة 2).
/// خصم العمولة عند الإكمال **تلقائي فعلياً** الآن (بند 10 — تصحيح معماري
/// موثَّق بالمرحلة 5) عبر `CommissionDeductionService`، مُشغَّلاً تفاعلياً
/// (StreamBuilder) فور تحوّل الحالة لـ`completed` — قابل لإعادة المحاولة
/// تلقائياً بأمان (idempotent) إن فشلت المحاولة الأولى لأي سبب شبكي.
class ActiveRideScreen extends StatelessWidget {
  const ActiveRideScreen({super.key, required this.rideRequestId});

  final String rideRequestId;

  DocumentReference<Map<String, dynamic>> get _ref =>
      FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).doc(rideRequestId);

  Future<void> _advance(String nextStatus) => _ref.update({'status': nextStatus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرحلة الحالية')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _ref.snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          if (data == null) return const Center(child: CircularProgressIndicator());

          final status = data['status'] as String? ?? 'accepted';
          final pickup = data['pickupAddress'] as String? ?? '';
          final destination = data['destinationAddress'] as String? ?? '';
          final fare = (data['fare'] as num?)?.toDouble() ?? 0;
          final walletDeducted = data['walletDeducted'] == true;

          if (status == 'completed' && !walletDeducted) {
            // إعادة المحاولة تلقائياً كل مرة تُعاد بناء الشجرة — آمنة تماماً
            // (idempotent) بفضل حارس walletDeducted بالقاعدة والخدمة معاً.
            const CommissionDeductionService().deductForCompletedRide(
              rideId: rideRequestId,
              driverUid: FirebaseAuth.instance.currentUser!.uid,
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.trip_origin, color: AppColors.success, size: 18), const SizedBox(width: 8), Expanded(child: Text(pickup))]),
                        const SizedBox(height: 8),
                        Row(children: [const Icon(Icons.place, color: AppColors.error, size: 18), const SizedBox(width: 8), Expanded(child: Text(destination))]),
                        const SizedBox(height: 8),
                        Text('${fare.toStringAsFixed(0)} ل.س — نقداً', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('حالة الرحلة: ${_statusLabel(status)}', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (status == 'accepted') MadaPrimaryButton(label: 'وصلت إلى نقطة الانطلاق', onPressed: () => _advance('arrived')),
                if (status == 'arrived') MadaPrimaryButton(label: 'بدء الرحلة', onPressed: () => _advance('onTrip')),
                if (status == 'onTrip') MadaPrimaryButton(label: 'إنهاء الرحلة', onPressed: () => _advance('completed')),
                if (status == 'completed') ...[
                  const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                  const SizedBox(height: 12),
                  const Text('انتهت الرحلة بنجاح', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  MadaPrimaryButton(label: 'العودة للرئيسية', onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'مقبولة — في الطريق للاستلام';
      case 'arrived':
        return 'وصل السائق لنقطة الانطلاق';
      case 'onTrip':
        return 'الرحلة جارية';
      case 'completed':
        return 'مكتملة';
      default:
        return status;
    }
  }
}
