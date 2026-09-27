import 'package:cloud_firestore/cloud_firestore.dart';

/// أدوات مساعدة مشتركة لتحويل حقول Firestore (Timestamp ↔ DateTime) بأمان،
/// تُستخدم من كل نماذج البيانات لتفادي تكرار نفس المنطق (بند 7).
DateTime? tsToDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

Timestamp? dateToTs(DateTime? date) => date == null ? null : Timestamp.fromDate(date);
