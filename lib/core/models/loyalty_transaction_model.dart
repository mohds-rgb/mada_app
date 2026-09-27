import 'firestore_helpers.dart';

/// loyaltyTransactions — بند 7.
class LoyaltyTransactionModel {
  const LoyaltyTransactionModel({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    this.referenceId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final int points; // موجب = مكتسب، سالب = مُستَبدَل
  final String type; // earned / redeemed / referralBonus
  final String? referenceId;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'points': points,
        'type': type,
        'referenceId': referenceId,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory LoyaltyTransactionModel.fromMap(String id, Map<String, dynamic> map) => LoyaltyTransactionModel(
        id: id,
        userId: map['userId'] as String? ?? '',
        points: (map['points'] as num?)?.toInt() ?? 0,
        type: map['type'] as String? ?? 'earned',
        referenceId: map['referenceId'] as String?,
        createdAt: tsToDate(map['createdAt']),
      );
}
