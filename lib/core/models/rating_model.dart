import 'firestore_helpers.dart';

/// ratings — بند 7.
class RatingModel {
  const RatingModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.tripId,
    this.bookingId,
    this.deliveryId,
    required this.stars,
    this.note,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String fromUserId;
  final String toUserId;
  final String? tripId;
  final String? bookingId;
  final String? deliveryId;
  final int stars; // 1-5
  final String? note;
  final List<String> tags;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'tripId': tripId,
        'bookingId': bookingId,
        'deliveryId': deliveryId,
        'stars': stars,
        'note': note,
        'tags': tags,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory RatingModel.fromMap(String id, Map<String, dynamic> map) => RatingModel(
        id: id,
        fromUserId: map['fromUserId'] as String? ?? '',
        toUserId: map['toUserId'] as String? ?? '',
        tripId: map['tripId'] as String?,
        bookingId: map['bookingId'] as String?,
        deliveryId: map['deliveryId'] as String?,
        stars: (map['stars'] as num?)?.toInt() ?? 5,
        note: map['note'] as String?,
        tags: List<String>.from(map['tags'] as List? ?? const []),
        createdAt: tsToDate(map['createdAt']),
      );
}
