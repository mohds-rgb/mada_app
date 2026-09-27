import 'firestore_helpers.dart';

/// businessContracts — بند 7، 14 ("مدى للأعمال").
class BusinessContractModel {
  const BusinessContractModel({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.monthlyRate,
    this.status = 'active',
    this.ridesIncluded = 0,
  });

  final String id;
  final String companyName;
  final String contactPerson;
  final double monthlyRate;
  final String status; // active / suspended / ended
  final int ridesIncluded;

  Map<String, dynamic> toMap() => {
        'companyName': companyName,
        'contactPerson': contactPerson,
        'monthlyRate': monthlyRate,
        'status': status,
        'ridesIncluded': ridesIncluded,
      };

  factory BusinessContractModel.fromMap(String id, Map<String, dynamic> map) => BusinessContractModel(
        id: id,
        companyName: map['companyName'] as String? ?? '',
        contactPerson: map['contactPerson'] as String? ?? '',
        monthlyRate: (map['monthlyRate'] as num?)?.toDouble() ?? 0,
        status: map['status'] as String? ?? 'active',
        ridesIncluded: (map['ridesIncluded'] as num?)?.toInt() ?? 0,
      );
}
