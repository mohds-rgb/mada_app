import 'firestore_helpers.dart';

/// lostItems — بند 7.
class LostItemModel {
  const LostItemModel({
    required this.id,
    required this.tripId,
    required this.reporterId,
    required this.itemDescription,
    this.status = 'open',
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String reporterId;
  final String itemDescription;
  final String status; // open / found / closed
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'tripId': tripId,
        'reporterId': reporterId,
        'itemDescription': itemDescription,
        'status': status,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory LostItemModel.fromMap(String id, Map<String, dynamic> map) => LostItemModel(
        id: id,
        tripId: map['tripId'] as String? ?? '',
        reporterId: map['reporterId'] as String? ?? '',
        itemDescription: map['itemDescription'] as String? ?? '',
        status: map['status'] as String? ?? 'open',
        createdAt: tsToDate(map['createdAt']),
      );
}
