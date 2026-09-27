import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';
import 'rating_screen.dart';

/// الرحلة النشطة من جهة العميل — تتبع لحظي لموقع السائق + بيانات الاتصال
/// + الانتقال للتقييم عند الإكمال (بند 8-المرحلة 1).
class CustomerActiveRideScreen extends StatelessWidget {
  const CustomerActiveRideScreen({super.key, required this.rideRequestId});

  final String rideRequestId;

  Future<void> _callDriver(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رحلتك')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).doc(rideRequestId).snapshots(),
        builder: (context, rideSnap) {
          final ride = rideSnap.data?.data();
          if (ride == null) return const Center(child: CircularProgressIndicator());

          final status = ride['status'] as String? ?? 'accepted';
          final driverId = ride['driverId'] as String?;
          final driverName = ride['driverName'] as String? ?? 'السائق';
          final driverPhone = ride['driverPhone'] as String?;
          final vehiclePlate = ride['vehiclePlate'] as String? ?? '';
          final pickup = LatLng((ride['pickupLat'] as num).toDouble(), (ride['pickupLng'] as num).toDouble());
          final destination = LatLng((ride['destinationLat'] as num).toDouble(), (ride['destinationLng'] as num).toDouble());

          if (status == 'completed') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (driverId != null) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => RatingScreen(rideRequestId: rideRequestId, driverId: driverId, driverName: driverName),
                ));
              }
            });
          }

          return Column(
            children: [
              SizedBox(
                height: 280,
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: driverId == null
                      ? null
                      : FirebaseFirestore.instance.collection(FirestoreCollections.vehicleLocations).doc(driverId).snapshots(),
                  builder: (context, locSnap) {
                    final loc = locSnap.data?.data();
                    final driverPoint = loc != null ? LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble()) : null;
                    final points = [pickup, destination, if (driverPoint != null) driverPoint];

                    return FlutterMap(
                      options: MapOptions(initialCameraFit: CameraFit.coordinates(coordinates: points, padding: const EdgeInsets.all(40))),
                      children: [
                        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.mada.app'),
                        MarkerLayer(markers: [
                          Marker(point: pickup, child: const Icon(Icons.trip_origin, color: AppColors.success)),
                          Marker(point: destination, child: const Icon(Icons.place, color: AppColors.error)),
                          if (driverPoint != null)
                            Marker(point: driverPoint, child: const Icon(Icons.local_taxi_rounded, color: AppColors.turquoise, size: 32)),
                        ]),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_statusLabel(status), style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(driverName),
                          subtitle: Text(vehiclePlate),
                          trailing: (driverPhone != null && driverPhone.isNotEmpty)
                              ? IconButton(icon: const Icon(Icons.call, color: AppColors.success), onPressed: () => _callDriver(driverPhone))
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'السائق في الطريق إليك';
      case 'arrived':
        return 'وصل السائق — بانتظارك';
      case 'onTrip':
        return 'الرحلة جارية';
      case 'completed':
        return 'انتهت الرحلة';
      default:
        return status;
    }
  }
}
