import 'firestore_helpers.dart';

/// status دورة حياة الرحلة (بند 7، 8-المرحلة1).
enum RideStatus { searching, accepted, arrived, onTrip, completed, cancelled }

RideStatus rideStatusFromString(String? v) {
  return RideStatus.values.firstWhere((e) => e.name == v, orElse: () => RideStatus.searching);
}

/// rideRequests — بند 7.
class RideRequestModel {
  const RideRequestModel({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationAddress,
    required this.fare,
    required this.distanceKm,
    required this.durationMin,
    this.paymentMethod = 'cash',
    this.status = RideStatus.searching,
    this.cancelReason,
    this.cancelFee = 0,
    this.scheduledFor,
    this.isForSomeoneElse = false,
    this.actualRiderName,
    this.actualRiderPhone,
    this.isFemaleDriverRequested = false,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String? driverId;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double destinationLat;
  final double destinationLng;
  final String destinationAddress;
  final double fare;
  final double distanceKm;
  final double durationMin;
  final String paymentMethod; // cash / sham_cash
  final RideStatus status;
  final String? cancelReason;
  final double cancelFee;
  final DateTime? scheduledFor; // "رحلة مجدولة"
  final bool isForSomeoneElse; // "اطلب لشخص آخر"
  final String? actualRiderName;
  final String? actualRiderPhone;
  final bool isFemaleDriverRequested; // فلتر "سائقة فقط"
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'driverId': driverId,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'pickupAddress': pickupAddress,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'destinationAddress': destinationAddress,
        'fare': fare,
        'distanceKm': distanceKm,
        'durationMin': durationMin,
        'paymentMethod': paymentMethod,
        'status': status.name,
        'cancelReason': cancelReason,
        'cancelFee': cancelFee,
        'scheduledFor': dateToTs(scheduledFor),
        'isForSomeoneElse': isForSomeoneElse,
        'actualRiderName': actualRiderName,
        'actualRiderPhone': actualRiderPhone,
        'isFemaleDriverRequested': isFemaleDriverRequested,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory RideRequestModel.fromMap(String id, Map<String, dynamic> map) => RideRequestModel(
        id: id,
        customerId: map['customerId'] as String? ?? '',
        driverId: map['driverId'] as String?,
        pickupLat: (map['pickupLat'] as num?)?.toDouble() ?? 0,
        pickupLng: (map['pickupLng'] as num?)?.toDouble() ?? 0,
        pickupAddress: map['pickupAddress'] as String? ?? '',
        destinationLat: (map['destinationLat'] as num?)?.toDouble() ?? 0,
        destinationLng: (map['destinationLng'] as num?)?.toDouble() ?? 0,
        destinationAddress: map['destinationAddress'] as String? ?? '',
        fare: (map['fare'] as num?)?.toDouble() ?? 0,
        distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
        durationMin: (map['durationMin'] as num?)?.toDouble() ?? 0,
        paymentMethod: map['paymentMethod'] as String? ?? 'cash',
        status: rideStatusFromString(map['status'] as String?),
        cancelReason: map['cancelReason'] as String?,
        cancelFee: (map['cancelFee'] as num?)?.toDouble() ?? 0,
        scheduledFor: tsToDate(map['scheduledFor']),
        isForSomeoneElse: map['isForSomeoneElse'] as bool? ?? false,
        actualRiderName: map['actualRiderName'] as String?,
        actualRiderPhone: map['actualRiderPhone'] as String?,
        isFemaleDriverRequested: map['isFemaleDriverRequested'] as bool? ?? false,
        createdAt: tsToDate(map['createdAt']),
      );
}
