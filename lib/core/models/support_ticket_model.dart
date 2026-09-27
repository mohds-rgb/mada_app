import 'firestore_helpers.dart';

/// supportTickets — بند 7.
class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.status = 'open',
    this.createdAt,
  });

  final String id;
  final String userId;
  final String subject;
  final String message;
  final String status; // open / inProgress / closed
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'subject': subject,
        'message': message,
        'status': status,
        'createdAt': dateToTs(createdAt ?? DateTime.now()),
      };

  factory SupportTicketModel.fromMap(String id, Map<String, dynamic> map) => SupportTicketModel(
        id: id,
        userId: map['userId'] as String? ?? '',
        subject: map['subject'] as String? ?? '',
        message: map['message'] as String? ?? '',
        status: map['status'] as String? ?? 'open',
        createdAt: tsToDate(map['createdAt']),
      );
}
