import 'firestore_helpers.dart';

/// wallets — بند 7 (رصيد السائق). محمي بالكامل عبر Firestore Rules —
/// لا كتابة مباشرة من السائق (استثناء مؤقت موثَّق، بند 6-8، 12).
class WalletModel {
  const WalletModel({required this.uid, this.balance = 0, this.updatedAt});

  final String uid;
  final double balance; // سالب = دَين مستحق (بند 10)
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
        'balance': balance,
        'updatedAt': dateToTs(updatedAt ?? DateTime.now()),
      };

  factory WalletModel.fromMap(String uid, Map<String, dynamic> map) => WalletModel(
        uid: uid,
        balance: (map['balance'] as num?)?.toDouble() ?? 0,
        updatedAt: tsToDate(map['updatedAt']),
      );
}

/// commissionSettlements — بند 7، 10 (تسوية ديون العمولة دورياً).
class CommissionSettlementModel {
  const CommissionSettlementModel({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.settledBy,
    this.date,
  });

  final String id;
  final String driverId;
  final double amount;
  final String settledBy; // uid الأدمن/المالك الذي سجّل التسوية
  final DateTime? date;

  Map<String, dynamic> toMap() => {
        'driverId': driverId,
        'amount': amount,
        'settledBy': settledBy,
        'date': dateToTs(date ?? DateTime.now()),
      };

  factory CommissionSettlementModel.fromMap(String id, Map<String, dynamic> map) => CommissionSettlementModel(
        id: id,
        driverId: map['driverId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        settledBy: map['settledBy'] as String? ?? '',
        date: tsToDate(map['date']),
      );
}
