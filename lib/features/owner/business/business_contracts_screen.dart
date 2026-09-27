import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// "مدى للأعمال" — عقود الشركات/المستشفيات/المدارس، فوترة موحَّدة
/// (بند 8-المرحلة 4-ز، 14).
class BusinessContractsScreen extends StatelessWidget {
  const BusinessContractsScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final rateController = TextEditingController();
    final ridesController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عقد عمل جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الجهة')),
              const SizedBox(height: 12),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: 'جهة الاتصال')),
              const SizedBox(height: 12),
              TextField(controller: rateController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'القيمة الشهرية')),
              const SizedBox(height: 12),
              TextField(controller: ridesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدد الرحلات المشمولة')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          MadaPrimaryButton(
            label: 'إنشاء',
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection(FirestoreCollections.businessContracts).add({
                'companyName': nameController.text.trim(),
                'contactPerson': contactController.text.trim(),
                'monthlyRate': double.tryParse(rateController.text) ?? 0,
                'status': 'active',
                'ridesIncluded': int.tryParse(ridesController.text) ?? 0,
              });
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('عقد جديد'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.businessContracts).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد عقود أعمال بعد'));

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              return Card(
                child: ListTile(
                  title: Text(data['companyName'] as String? ?? ''),
                  subtitle: Text('${data['contactPerson'] ?? ''} — ${(data['monthlyRate'] as num?) ?? 0} ل.س/شهر'),
                  trailing: Text(data['status'] as String? ?? 'active'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
