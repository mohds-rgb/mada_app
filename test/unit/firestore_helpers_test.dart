import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/firestore_helpers.dart';

void main() {
  group('firestore_helpers — تحويل Timestamp آمن', () {
    test('tsToDate يُعيد null عند إدخال null', () {
      expect(tsToDate(null), null);
    });

    test('dateToTs يُعيد null عند إدخال null', () {
      expect(dateToTs(null), null);
    });

    test('DateTime يمر كما هو دون تحويل خاطئ', () {
      final now = DateTime(2026, 1, 1);
      expect(tsToDate(now), now);
    });
  });
}
