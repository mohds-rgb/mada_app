import 'firestore_helpers.dart';

/// vehicleLocations — بند 7. تردد الكتابة يتبع adminSettings.locationUpdateIntervalSec
/// (20 ثانية افتراضياً — الحساب المُصحَّح ببند 8-0.5).
class VehicleLocationModel {
  const VehicleLocationModel({
    required this.vehicleId,
    required this.lat,
    required this.lng,
    this.updatedAt,
    this.source = 'driverApp',
  });

  final String vehicleId;
  final double lat;
  final double lng;
  final DateTime? updatedAt;
  final String source; // driverApp / officeApp

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'updatedAt': dateToTs(updatedAt ?? DateTime.now()),
        'source': source,
      };

  factory VehicleLocationModel.fromMap(String vehicleId, Map<String, dynamic> map) => VehicleLocationModel(
        vehicleId: vehicleId,
        lat: (map['lat'] as num?)?.toDouble() ?? 0,
        lng: (map['lng'] as num?)?.toDouble() ?? 0,
        updatedAt: tsToDate(map['updatedAt']),
        source: map['source'] as String? ?? 'driverApp',
      );
}
