import 'firestore_helpers.dart';

/// bannedDevices — بند 7، 12-هـ، 13-د. يمنع الالتفاف على الحظر بحساب جديد
/// على نفس الجهاز.
class BannedDeviceModel {
  const BannedDeviceModel({
    required this.deviceFingerprint,
    required this.reason,
    this.bannedAt,
  });

  final String deviceFingerprint;
  final String reason;
  final DateTime? bannedAt;

  Map<String, dynamic> toMap() => {
        'reason': reason,
        'bannedAt': dateToTs(bannedAt ?? DateTime.now()),
      };

  factory BannedDeviceModel.fromMap(String deviceFingerprint, Map<String, dynamic> map) => BannedDeviceModel(
        deviceFingerprint: deviceFingerprint,
        reason: map['reason'] as String? ?? '',
        bannedAt: tsToDate(map['bannedAt']),
      );
}
