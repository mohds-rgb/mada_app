import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/mada_primary_button.dart';
import 'customer_active_ride_screen.dart';

/// "جارٍ البحث عن سائق" — يستمع لمستند rideRequests حيّاً (بند 8-المرحلة 1، 2).
/// فور قبول أي سائق (status يتغيّر عن 'searching')، ينتقل تلقائياً لشاشة
/// الرحلة النشطة (CustomerActiveRideScreen) بتتبع لحظي حقيقي.
class RideSearchingScreen extends StatelessWidget {
  const RideSearchingScreen({super.key, required this.rideRequestId});

  final String rideRequestId;

  Future<void> _cancel(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.rideRequests)
        .doc(rideRequestId)
        .update({'status': 'cancelled', 'cancelReason': 'ألغى العميل قبل تعيين سائق'});
    if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب رحلة')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).doc(rideRequestId).snapshots(),
        builder: (context, snapshot) {
          final status = snapshot.data?.data()?['status'] as String? ?? 'searching';

          if (status != 'searching' && status != 'cancelled') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (_) => CustomerActiveRideScreen(rideRequestId: rideRequestId)));
            });
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == 'searching') ...[
                    const CircularProgressIndicator(color: AppColors.turquoise),
                    const SizedBox(height: 24),
                    Text('جارٍ البحث عن سائق قريب منك...', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('سيصلك إشعار فور قبول أحد السائقين طلبك.', textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    SizedBox(width: 200, child: MadaPrimaryButton(label: 'إلغاء الطلب', onPressed: () => _cancel(context))),
                  ] else if (status == 'cancelled') ...[
                    const Icon(Icons.cancel_outlined, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('تم إلغاء الطلب'),
                  ] else ...[
                    const Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                    const SizedBox(height: 16),
                    Text('حالة الطلب: $status'),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
