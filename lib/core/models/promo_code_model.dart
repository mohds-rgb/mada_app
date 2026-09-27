import 'firestore_helpers.dart';

/// promoCodes — بند 7.
class PromoCodeModel {
  const PromoCodeModel({
    required this.code,
    required this.discountValue,
    this.discountType = 'fixed',
    this.maxUses = 0,
    this.usedCount = 0,
    this.isActive = true,
    this.expiresAt,
  });

  final String code;
  final double discountValue;
  final String discountType; // fixed / percentage
  final int maxUses; // 0 = بلا حد
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;

  Map<String, dynamic> toMap() => {
        'discountValue': discountValue,
        'discountType': discountType,
        'maxUses': maxUses,
        'usedCount': usedCount,
        'isActive': isActive,
        'expiresAt': dateToTs(expiresAt),
      };

  factory PromoCodeModel.fromMap(String code, Map<String, dynamic> map) => PromoCodeModel(
        code: code,
        discountValue: (map['discountValue'] as num?)?.toDouble() ?? 0,
        discountType: map['discountType'] as String? ?? 'fixed',
        maxUses: (map['maxUses'] as num?)?.toInt() ?? 0,
        usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
        isActive: map['isActive'] as bool? ?? true,
        expiresAt: tsToDate(map['expiresAt']),
      );
}
