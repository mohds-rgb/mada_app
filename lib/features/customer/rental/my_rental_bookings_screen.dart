import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/rental_policy_calculator.dart';
import '../../../core/services/rental_tracking_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// حجوزات التأجير الخاصة بالعميل — إلغاء (بسياسة استرداد متدرجة) وطلب
/// تمديد (بند 8-المرحلة 1، 3).
class MyRentalBookingsScreen extends StatelessWidget {
  const MyRentalBookingsScreen({super.key});

  Future<void> _cancel(BuildContext context, String bookingId, DateTime startDate, double depositAmount) async {
    final refund = const RentalPolicyCalculator().refundAmount(now: DateTime.now(), startDate: startDate, depositAmount: depositAmount);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: Text('سيُسترَد لك ${refund.toStringAsFixed(0)} ل.س من أصل عربون ${depositAmount.toStringAsFixed(0)} ل.س حسب سياسة الإلغاء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('تراجع')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأكيد الإلغاء')),
        ],
      ),
    );
    if (confirmed != true) return;

    await FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).doc(bookingId).update({'status': 'cancelled'});
  }

  Future<void> _requestExtension(BuildContext context, String bookingId, DateTime currentEnd) async {
    final newEnd = await showDatePicker(
      context: context,
      initialDate: currentEnd.add(const Duration(days: 1)),
      firstDate: currentEnd.add(const Duration(days: 1)),
      lastDate: currentEnd.add(const Duration(days: 30)),
    );
    if (newEnd == null) return;

    await FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).doc(bookingId).update({
      'extensionRequests': FieldValue.arrayUnion([
        {'requestedNewEndDate': Timestamp.fromDate(newEnd), 'status': 'pending', 'requestedAt': Timestamp.now()},
      ]),
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dateFormat = DateFormat('d/M');

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.rentalBookings)
            .where('customerId', isEqualTo: uid)
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد حجوزات بعد'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final status = data['status'] as String? ?? 'pending';
              final start = (data['startDate'] as Timestamp).toDate();
              final end = (data['endDate'] as Timestamp).toDate();
              final total = (data['total'] as num?)?.toDouble() ?? 0;
              final deposit = (data['depositAmount'] as num?)?.toDouble() ?? 0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dateFormat.format(start)} — ${dateFormat.format(end)}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${total.toStringAsFixed(0)} ل.س — ${_statusLabel(status)}'),
                      if (status == 'pending' || status == 'confirmed') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _cancel(context, docs[i].id, start, deposit),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('إلغاء الحجز'),
                          ),
                        ),
                      ],
                      if (status == 'active') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(onPressed: () => _requestExtension(context, docs[i].id, end), child: const Text('طلب تمديد')),
                        ),
                        _ActiveRentalTrackingSection(bookingId: docs[i].id, vehicleId: data['vehicleId'] as String? ?? '', data: data),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار موافقة المكتب';
      case 'confirmed':
        return 'مؤكَّد — بانتظار الاستلام';
      case 'active':
        return 'قيد التأجير حالياً';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }
}

/// قسم موافقة/تحكّم تتبع الموقع أثناء حجز نشط (بند 11) — نص الموافقة
/// حرفياً كما بالمواصفة، مع زر "انقطع التتبع" لإيقافه يدوياً في أي وقت.
class _ActiveRentalTrackingSection extends StatefulWidget {
  const _ActiveRentalTrackingSection({required this.bookingId, required this.vehicleId, required this.data});

  final String bookingId;
  final String vehicleId;
  final Map<String, dynamic> data;

  @override
  State<_ActiveRentalTrackingSection> createState() => _ActiveRentalTrackingSectionState();
}

class _ActiveRentalTrackingSectionState extends State<_ActiveRentalTrackingSection> {
  RentalTrackingService? _service;

  bool get _consentGiven => widget.data['locationTrackingEnabled'] == true;

  @override
  void didUpdateWidget(covariant _ActiveRentalTrackingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إن أُعيد بناء الودجت (تحديث حيّ من Firestore) وكانت الموافقة قد
    // أُعطيت للتو من مكان آخر، تأكّد أن الخدمة تعمل فعلاً.
    if (_consentGiven && _service == null && widget.vehicleId.isNotEmpty) {
      _startTracking();
    }
  }

  Future<void> _giveConsentAndStart() async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).doc(widget.bookingId).update({
      'locationTrackingEnabled': true,
      'trackingConsentGivenAt': FieldValue.serverTimestamp(),
    });
    _startTracking();
  }

  void _startTracking() {
    if (widget.vehicleId.isEmpty) return;
    final service = RentalTrackingService(widget.vehicleId);
    service.start();
    setState(() => _service = service);
  }

  Future<void> _stopTracking() async {
    await _service?.stop();
    setState(() => _service = null);
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_consentGiven) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(rentalTrackingConsentText, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            MadaPrimaryButton(label: 'متابعة', onPressed: _giveConsentAndStart),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(_service != null ? Icons.location_on : Icons.location_off, color: _service != null ? AppColors.success : AppColors.textMutedLight, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(_service != null ? 'مشاركة الموقع فعّالة مع المكتب' : 'التتبع متوقف')),
          if (_service != null)
            TextButton(
              onPressed: _stopTracking,
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('انقطع التتبع'),
            )
          else
            TextButton(onPressed: _startTracking, child: const Text('استئناف')),
        ],
      ),
    );
  }
}
