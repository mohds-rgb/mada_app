import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';
import 'booking_photo_doc_screen.dart';

/// إدارة حجوزات المكتب — قبول/رفض، توثيق استلام/إرجاع، طلبات تمديد
/// (بند 8-المرحلة 3).
class OfficeBookingsScreen extends StatelessWidget {
  const OfficeBookingsScreen({super.key});

  Future<void> _respond(String bookingId, String newStatus) {
    return FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).doc(bookingId).update({'status': newStatus});
  }

  Future<void> _respondExtension(String bookingId, Map<String, dynamic> booking, int requestIndex, bool approve) async {
    final requests = List<Map<String, dynamic>>.from(booking['extensionRequests'] as List? ?? const []);
    final req = Map<String, dynamic>.from(requests[requestIndex]);
    req['status'] = approve ? 'approved' : 'rejected';
    requests[requestIndex] = req;

    final updates = <String, dynamic>{'extensionRequests': requests};
    if (approve && req['requestedNewEndDate'] != null) {
      updates['endDate'] = req['requestedNewEndDate'];
    }
    await FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).doc(bookingId).update(updates);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final dateFormat = DateFormat('d/M');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestoreCollections.rentalBookings)
          .where('officeId', isEqualTo: uid)
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
            final start = (data['startDate'] as Timestamp?)?.toDate();
            final end = (data['endDate'] as Timestamp?)?.toDate();
            final total = (data['total'] as num?)?.toDouble() ?? 0;
            final lateFee = (data['lateFee'] as num?)?.toDouble() ?? 0;
            final extensionRequests = List<Map<String, dynamic>>.from(data['extensionRequests'] as List? ?? const []);
            final pendingExtIndex = extensionRequests.indexWhere((r) => r['status'] == 'pending');

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      start != null && end != null ? '${dateFormat.format(start)} — ${dateFormat.format(end)}' : '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${total.toStringAsFixed(0)} ل.س — ${_statusLabel(status)}'),
                    if (lateFee > 0) Text('غرامة تأخير: ${lateFee.toStringAsFixed(0)} ل.س', style: const TextStyle(color: AppColors.error)),
                    if (status == 'pending') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => _respond(docs[i].id, 'cancelled'), child: const Text('رفض'))),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: () => _respond(docs[i].id, 'confirmed'), child: const Text('قبول'))),
                        ],
                      ),
                    ],
                    if (status == 'confirmed') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('توثيق الاستلام'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookingPhotoDocScreen(bookingId: docs[i].id, isPickup: true)),
                          ),
                        ),
                      ),
                    ],
                    if (status == 'active') ...[
                      if (pendingExtIndex != -1) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('طلب تمديد بانتظار ردّك', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _respondExtension(docs[i].id, data, pendingExtIndex, false),
                                      child: const Text('رفض التمديد'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _respondExtension(docs[i].id, data, pendingExtIndex, true),
                                      child: const Text('قبول التمديد'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('توثيق الإرجاع'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BookingPhotoDocScreen(bookingId: docs[i].id, isPickup: false, scheduledEndDate: end)),
                          ),
                        ),
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
      case 'pending':
        return 'بانتظار ردّك';
      case 'confirmed':
        return 'مؤكَّد — بانتظار الاستلام';
      case 'active':
        return 'قيد التأجير حالياً';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'مرفوض/ملغى';
      default:
        return status;
    }
  }
}
