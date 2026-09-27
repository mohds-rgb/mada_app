import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../core/theme/app_colors.dart';

/// إدارة السائقين — اعتماد/حظر (بند 8-المرحلة 4-ب). يُزيل الاعتماد اليدوي
/// عبر Firebase Console الذي وثَّقناه كقيد مؤقت بالمرحلة 2.
class DriversManagementScreen extends StatelessWidget {
  const DriversManagementScreen({super.key, this.isOwner = true});

  /// الأدمن التشغيلي (isOwner=false) يعتمد الوثائق فقط — لا يحظر (بند 8-4.5).
  final bool isOwner;

  Future<void> _setStatus(BuildContext context, String uid, String status) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(uid).update({'status': status});
    await const AuditLogService().log(action: 'driverStatusChanged', targetId: uid, details: {'newStatus': status});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'قيد المراجعة'), Tab(text: 'معتمَد'), Tab(text: 'محظور')]),
          Expanded(
            child: TabBarView(
              children: [
                _DriverList(status: 'pending', isOwner: isOwner, onSetStatus: (uid, s) => _setStatus(context, uid, s)),
                _DriverList(status: 'approved', isOwner: isOwner, onSetStatus: (uid, s) => _setStatus(context, uid, s)),
                _DriverList(status: 'blocked', isOwner: isOwner, onSetStatus: (uid, s) => _setStatus(context, uid, s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverList extends StatelessWidget {
  const _DriverList({required this.status, required this.isOwner, required this.onSetStatus});
  final String status;
  final bool isOwner;
  final void Function(String uid, String newStatus) onSetStatus;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.drivers).where('status', isEqualTo: status).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا يوجد'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final uid = docs[i].id;
            final walletBalance = (data['walletBalance'] as num?)?.toDouble() ?? 0;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['fullName'] as String? ?? '(بلا اسم بعد)', style: Theme.of(context).textTheme.titleMedium),
                    Text('${data['vehicleType'] ?? ''} — ${data['vehiclePlate'] ?? ''}'),
                    Text('رخصة: ${data['licenseNumber'] ?? '—'}'),
                    Text(
                      'المحفظة: ${walletBalance.toStringAsFixed(0)} ل.س',
                      style: TextStyle(color: walletBalance < 0 ? AppColors.error : AppColors.success),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (status != 'approved')
                          Expanded(child: OutlinedButton(onPressed: () => onSetStatus(uid, 'approved'), child: const Text('اعتماد'))),
                        if (status != 'approved') const SizedBox(width: 8),
                        if (status != 'blocked' && isOwner)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                              onPressed: () => onSetStatus(uid, 'blocked'),
                              child: const Text('حظر'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
