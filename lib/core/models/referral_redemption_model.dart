import 'firestore_helpers.dart';

/// referralRedemptions — بند 7، 13-د.
class ReferralRedemptionModel {
  const ReferralRedemptionModel({
    required this.id,
    required this.referralCode,
    required this.newUserId,
    required this.rewardType,
    required this.rewardValue,
    this.date,
  });

  final String id;
  final String referralCode;
  final String newUserId;
  final String rewardType; // loyaltyPoints / freeTripDiscount
  final double rewardValue;
  final DateTime? date;

  Map<String, dynamic> toMap() => {
        'referralCode': referralCode,
        'newUserId': newUserId,
        'rewardType': rewardType,
        'rewardValue': rewardValue,
        'date': dateToTs(date ?? DateTime.now()),
      };

  factory ReferralRedemptionModel.fromMap(String id, Map<String, dynamic> map) => ReferralRedemptionModel(
        id: id,
        referralCode: map['referralCode'] as String? ?? '',
        newUserId: map['newUserId'] as String? ?? '',
        rewardType: map['rewardType'] as String? ?? 'loyaltyPoints',
        rewardValue: (map['rewardValue'] as num?)?.toDouble() ?? 0,
        date: tsToDate(map['date']),
      );
}
