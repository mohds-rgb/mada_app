import 'firestore_helpers.dart';

/// trustedContacts — بند 7 (مشاركة الرحلة مع جهات ثقة، بند 13-ج).
class TrustedContactModel {
  const TrustedContactModel({
    required this.id,
    required this.customerId,
    required this.contactPhone,
    this.contactName,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String contactPhone;
  final String? contactName;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'contactPhone': contactPhone,
        'contactName': contactName,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory TrustedContactModel.fromMap(String id, Map<String, dynamic> map) => TrustedContactModel(
        id: id,
        customerId: map['customerId'] as String? ?? '',
        contactPhone: map['contactPhone'] as String? ?? '',
        contactName: map['contactName'] as String?,
        createdAt: tsToDate(map['createdAt']),
      );
}
