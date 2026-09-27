import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// أكواد الخصم — إنشاء/تفعيل-تعطيل (بند 8-المرحلة 4-هـ).
class PromoCodesScreen extends StatelessWidget {
  const PromoCodesScreen({super.key});

  Future<void> _toggle(String code, bool current) {
    return FirebaseFirestore.instance.collection(FirestoreCollections.promoCodes).doc(code).update({'isActive': !current});
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final codeController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'fixed';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('كود خصم جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: codeController, decoration: const InputDecoration(labelText: 'الكود (بالإنجليزية)')),
              const SizedBox(height: 12),
              TextField(controller: valueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'القيمة')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [DropdownMenuItem(value: 'fixed', child: Text('مبلغ ثابت')), DropdownMenuItem(value: 'percentage', child: Text('نسبة مئوية'))],
                onChanged: (v) => setState(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            MadaPrimaryButton(
              label: 'إنشاء',
              onPressed: () async {
                final code = codeController.text.trim().toUpperCase();
                if (code.isEmpty) return;
                await FirebaseFirestore.instance.collection(FirestoreCollections.promoCodes).doc(code).set({
                  'discountValue': double.tryParse(valueController.text) ?? 0,
                  'discountType': type,
                  'maxUses': 0,
                  'usedCount': 0,
                  'isActive': true,
                  'expiresAt': null,
                });
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('كود جديد'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.promoCodes).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد أكواد خصم بعد'));

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final isActive = data['isActive'] as bool? ?? true;
              final discountType = data['discountType'] as String? ?? 'fixed';
              final value = (data['discountValue'] as num?) ?? 0;
              return Card(
                child: SwitchListTile(
                  value: isActive,
                  onChanged: (_) => _toggle(docs[i].id, isActive),
                  title: Text(docs[i].id),
                  subtitle: Text(discountType == 'fixed' ? '$value ل.س' : '$value%'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
