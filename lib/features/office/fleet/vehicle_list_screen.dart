import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import 'vehicle_form_screen.dart';

/// قائمة أسطول المكتب — إضافة/تعديل سيارة (بند 8-المرحلة 3).
class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('إضافة سيارة'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).where('officeId', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد سيارات بعد — أضف أول سيارة لأسطولك'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final photos = List<String>.from(data['photos'] as List? ?? const []);
              final status = data['status'] as String? ?? 'available';
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: photos.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(photos.first, width: 56, height: 56, fit: BoxFit.cover))
                      : const CircleAvatar(child: Icon(Icons.directions_car)),
                  title: Text(data['licensePlate'] as String? ?? ''),
                  subtitle: Text('${(data['priceDaily'] as num?) ?? 0} ل.س/يوم — ${_statusLabel(status)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VehicleFormScreen(existingVehicleId: docs[i].id, existingData: data)),
                    ),
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
      case 'rented':
        return 'مؤجَّرة حالياً';
      case 'maintenance':
        return 'صيانة';
      default:
        return 'متاحة';
    }
  }
}
