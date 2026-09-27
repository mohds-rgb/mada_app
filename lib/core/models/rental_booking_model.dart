import 'firestore_helpers.dart';

/// rentalBookings — بند 7.
class RentalBookingModel {
  const RentalBookingModel({
    required this.id,
    required this.customerId,
    required this.officeId,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.total,
    required this.depositAmount,
    this.depositStatus = 'pending',
    this.status = 'pending',
    this.pickupPhotos = const [],
    this.returnPhotos = const [],
    this.extensionRequests = const [],
    this.lateFee = 0,
  });

  final String id;
  final String customerId;
  final String officeId;
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final double total;
  final double depositAmount; // بند 7، نسبة من adminSettings.depositPercentage
  final String depositStatus; // pending / held / refunded / forfeited
  final String status; // pending / active / completed / cancelled / disputed
  final List<String> pickupPhotos; // توثيق الاستلام (بند 13-ج)
  final List<String> returnPhotos; // توثيق الإرجاع
  final List<Map<String, dynamic>> extensionRequests;
  final double lateFee;

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'officeId': officeId,
        'vehicleId': vehicleId,
        'startDate': dateToTs(startDate),
        'endDate': dateToTs(endDate),
        'total': total,
        'depositAmount': depositAmount,
        'depositStatus': depositStatus,
        'status': status,
        'pickupPhotos': pickupPhotos,
        'returnPhotos': returnPhotos,
        'extensionRequests': extensionRequests,
        'lateFee': lateFee,
      };

  factory RentalBookingModel.fromMap(String id, Map<String, dynamic> map) => RentalBookingModel(
        id: id,
        customerId: map['customerId'] as String? ?? '',
        officeId: map['officeId'] as String? ?? '',
        vehicleId: map['vehicleId'] as String? ?? '',
        startDate: tsToDate(map['startDate']) ?? DateTime.now(),
        endDate: tsToDate(map['endDate']) ?? DateTime.now(),
        total: (map['total'] as num?)?.toDouble() ?? 0,
        depositAmount: (map['depositAmount'] as num?)?.toDouble() ?? 0,
        depositStatus: map['depositStatus'] as String? ?? 'pending',
        status: map['status'] as String? ?? 'pending',
        pickupPhotos: List<String>.from(map['pickupPhotos'] as List? ?? const []),
        returnPhotos: List<String>.from(map['returnPhotos'] as List? ?? const []),
        extensionRequests: List<Map<String, dynamic>>.from(map['extensionRequests'] as List? ?? const []),
        lateFee: (map['lateFee'] as num?)?.toDouble() ?? 0,
      );
}
