import 'firestore_helpers.dart';

/// vehicles — بند 7 (سيارات مكاتب التأجير).
class VehicleModel {
  const VehicleModel({
    required this.vehicleId,
    required this.officeId,
    required this.photos,
    required this.priceDaily,
    required this.priceWeekly,
    required this.priceMonthly,
    required this.transmission,
    required this.seats,
    required this.licensePlate,
    this.status = 'available',
    this.features = const [],
  });

  final String vehicleId;
  final String officeId;
  final List<String> photos; // روابط Cloudinary
  final double priceDaily;
  final double priceWeekly;
  final double priceMonthly;
  final String transmission; // automatic / manual
  final int seats;
  final String licensePlate;
  final String status; // available / rented / maintenance
  final List<String> features;

  Map<String, dynamic> toMap() => {
        'officeId': officeId,
        'photos': photos,
        'priceDaily': priceDaily,
        'priceWeekly': priceWeekly,
        'priceMonthly': priceMonthly,
        'transmission': transmission,
        'seats': seats,
        'licensePlate': licensePlate,
        'status': status,
        'features': features,
      };

  factory VehicleModel.fromMap(String vehicleId, Map<String, dynamic> map) => VehicleModel(
        vehicleId: vehicleId,
        officeId: map['officeId'] as String? ?? '',
        photos: List<String>.from(map['photos'] as List? ?? const []),
        priceDaily: (map['priceDaily'] as num?)?.toDouble() ?? 0,
        priceWeekly: (map['priceWeekly'] as num?)?.toDouble() ?? 0,
        priceMonthly: (map['priceMonthly'] as num?)?.toDouble() ?? 0,
        transmission: map['transmission'] as String? ?? 'automatic',
        seats: (map['seats'] as num?)?.toInt() ?? 4,
        licensePlate: map['licensePlate'] as String? ?? '',
        status: map['status'] as String? ?? 'available',
        features: List<String>.from(map['features'] as List? ?? const []),
      );
}
