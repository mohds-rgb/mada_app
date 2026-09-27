import 'firestore_helpers.dart';
import 'ride_request_model.dart' show RideStatus, rideStatusFromString;

/// deliveryRequests — بند 7 (توصيل الطرود، نفس شبكة السائقين).
class DeliveryRequestModel {
  const DeliveryRequestModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.packageDescription,
    required this.packagePhotoUrl,
    required this.recipientName,
    required this.recipientPhone,
    required this.fare,
    this.paymentMethod = 'cash',
    this.status = RideStatus.searching,
    this.deliveryProofPhotoUrl,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String? driverId;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final String packageDescription;
  final String packagePhotoUrl; // إلزامية (بند 8، المرحلة 1)
  final String recipientName;
  final String recipientPhone;
  final double fare;
  final String paymentMethod;
  final RideStatus status;
  final String? deliveryProofPhotoUrl; // صورة إثبات تسليم من السائق
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'driverId': driverId,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'packageDescription': packageDescription,
        'packagePhotoUrl': packagePhotoUrl,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'fare': fare,
        'paymentMethod': paymentMethod,
        'status': status.name,
        'deliveryProofPhotoUrl': deliveryProofPhotoUrl,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory DeliveryRequestModel.fromMap(String id, Map<String, dynamic> map) => DeliveryRequestModel(
        id: id,
        customerId: map['customerId'] as String? ?? '',
        driverId: map['driverId'] as String?,
        pickupLat: (map['pickupLat'] as num?)?.toDouble() ?? 0,
        pickupLng: (map['pickupLng'] as num?)?.toDouble() ?? 0,
        destinationLat: (map['destinationLat'] as num?)?.toDouble() ?? 0,
        destinationLng: (map['destinationLng'] as num?)?.toDouble() ?? 0,
        packageDescription: map['packageDescription'] as String? ?? '',
        packagePhotoUrl: map['packagePhotoUrl'] as String? ?? '',
        recipientName: map['recipientName'] as String? ?? '',
        recipientPhone: map['recipientPhone'] as String? ?? '',
        fare: (map['fare'] as num?)?.toDouble() ?? 0,
        paymentMethod: map['paymentMethod'] as String? ?? 'cash',
        status: rideStatusFromString(map['status'] as String?),
        deliveryProofPhotoUrl: map['deliveryProofPhotoUrl'] as String?,
        createdAt: tsToDate(map['createdAt']),
      );
}
