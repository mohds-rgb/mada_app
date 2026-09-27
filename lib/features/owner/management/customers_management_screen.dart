import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../core/theme/app_colors.dart';

/// إدارة العملاء — عرض/حظر (بند 8-المرحلة 4-ب).
class CustomersManagementScreen extends StatelessWidget {
  const CustomersManagementScreen({super.key});

  Future<void> _setStatus(String uid, String status) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid).update({'accountStatus': status});
    await const AuditLogService().log(action: 'customerAccountStatusChanged', targetId: uid, details: {'newStatus': status});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.users).where('role', isEqualTo: 'customer').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا يوجد عملاء بعد'));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final uid = docs[i].id;
            final status = data['accountStatus'] as String? ?? 'active';

            return Card(
              child: ListTile(
                title: Text(data['displayName'] as String? ?? data['email'] as String? ?? uid),
                subtitle: Text(status == 'active' ? 'نشط' : status == 'suspended' ? 'موقوف مؤقتاً' : 'محظور'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _setStatus(uid, v),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'active', child: Text('تفعيل')),
                    PopupMenuItem(value: 'suspended', child: Text('إيقاف مؤقت')),
                    PopupMenuItem(value: 'banned', child: Text('حظر نهائي')),
                  ],
                  child: Icon(Icons.more_vert, color: status == 'active' ? null : AppColors.error),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
