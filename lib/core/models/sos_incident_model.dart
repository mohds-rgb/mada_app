import 'firestore_helpers.dart';

/// sosIncidents — بند 7، 13-أ (أولوية قصوى للمالك، بند 22).
class SosIncidentModel {
  const SosIncidentModel({
    required this.id,
    required this.userId,
    this.tripId,
    required this.lat,
    required this.lng,
    this.status = 'open',
    this.isFakeCancel = false,
    this.timestamp,
  });

  final String id;
  final String userId;
  final String? tripId;
  final double lat;
  final double lng;
  final String status; // open / acknowledged / resolved
  final bool isFakeCancel; // بلاغ كيدي/إلغاء وهمي مكتشَف لاحقاً
  final DateTime? timestamp;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'tripId': tripId,
        'lat': lat,
        'lng': lng,
        'status': status,
        'isFakeCancel': isFakeCancel,
        'timestamp': dateToTs(timestamp ?? DateTime.now()),
      };

  factory SosIncidentModel.fromMap(String id, Map<String, dynamic> map) => SosIncidentModel(
        id: id,
        userId: map['userId'] as String? ?? '',
        tripId: map['tripId'] as String?,
        lat: (map['lat'] as num?)?.toDouble() ?? 0,
        lng: (map['lng'] as num?)?.toDouble() ?? 0,
        status: map['status'] as String? ?? 'open',
        isFakeCancel: map['isFakeCancel'] as bool? ?? false,
        timestamp: tsToDate(map['timestamp']),
      );
}
