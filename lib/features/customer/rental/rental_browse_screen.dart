import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import 'my_rental_bookings_screen.dart';
import 'vehicle_booking_screen.dart';

/// تصفح سيارات التأجير المتاحة من كل المكاتب المعتمدة (بند 8-المرحلة 1، 3).
class RentalBrowseScreen extends StatelessWidget {
  const RentalBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استأجر سيارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'حجوزاتي',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRentalBookingsScreen())),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).where('status', isEqualTo: 'available').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد سيارات متاحة حالياً'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final photos = List<String>.from(data['photos'] as List? ?? const []);
              return Card(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VehicleBookingScreen(vehicleId: docs[i].id, vehicleData: data)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: photos.isNotEmpty
                              ? Image.network(photos.first, width: 90, height: 70, fit: BoxFit.cover)
                              : Container(width: 90, height: 70, color: Colors.grey.shade300, child: const Icon(Icons.directions_car)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${(data['priceDaily'] as num?) ?? 0} ل.س / يوم', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '${data['seats'] ?? 4} مقاعد — ${(data['transmission'] as String? ?? 'automatic') == 'automatic' ? 'أوتوماتيك' : 'يدوي'}',
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      ],
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
}
