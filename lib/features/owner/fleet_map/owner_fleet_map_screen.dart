import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';

/// خريطة موحَّدة حيّة لكل السائقين المتصلين معاً (بند 8-المرحلة 4-أ).
class OwnerFleetMapScreen extends StatelessWidget {
  const OwnerFleetMapScreen({super.key});

  static const _daraaCenter = LatLng(32.6189, 36.1021);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.vehicleLocations).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final markers = docs.map((d) {
          final data = d.data();
          return Marker(
            point: LatLng((data['lat'] as num).toDouble(), (data['lng'] as num).toDouble()),
            child: const Icon(Icons.local_taxi_rounded, color: AppColors.turquoise, size: 28),
          );
        }).toList();

        return Stack(
          children: [
            FlutterMap(
              options: const MapOptions(initialCenter: _daraaCenter, initialZoom: 13),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.mada.app'),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('${markers.length} مركبة متصلة الآن'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
