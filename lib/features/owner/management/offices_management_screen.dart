import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../core/theme/app_colors.dart';

/// إدارة مكاتب التأجير — اعتماد/حظر (بند 8-المرحلة 4-ب). يُزيل الاعتماد
/// اليدوي عبر Firebase Console الذي وثَّقناه كقيد مؤقت بالمرحلة 3.
class OfficesManagementScreen extends StatelessWidget {
  const OfficesManagementScreen({super.key});

  Future<void> _setStatus(BuildContext context, String uid, String status) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.offices).doc(uid).update({'approvalStatus': status});
    await const AuditLogService().log(action: 'officeApprovalChanged', targetId: uid, details: {'newStatus': status});
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
                _OfficeList(status: 'pending', onSetStatus: (uid, s) => _setStatus(context, uid, s)),
                _OfficeList(status: 'approved', onSetStatus: (uid, s) => _setStatus(context, uid, s)),
                _OfficeList(status: 'blocked', onSetStatus: (uid, s) => _setStatus(context, uid, s)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficeList extends StatelessWidget {
  const _OfficeList({required this.status, required this.onSetStatus});
  final String status;
  final void Function(String uid, String newStatus) onSetStatus;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.offices).where('approvalStatus', isEqualTo: status).snapshots(),
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

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] as String? ?? '', style: Theme.of(context).textTheme.titleMedium),
                    Text('الاشتراك: ${data['subscriptionStatus'] ?? 'active'}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (status != 'approved')
                          Expanded(child: OutlinedButton(onPressed: () => onSetStatus(uid, 'approved'), child: const Text('اعتماد'))),
                        if (status != 'approved') const SizedBox(width: 8),
                        if (status != 'blocked')
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
