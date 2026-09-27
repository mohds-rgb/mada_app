import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/services/version_check_service.dart';

void main() {
  const svc = VersionCheckService();

  group('VersionCheckService (بند 16 — Force Update)', () {
    test('إصدار أقل من الحد الأدنى يُعتبر متأخراً', () {
      expect(svc.isBelowMinimum('1.0.0', '1.1.0'), true);
      expect(svc.isBelowMinimum('0.9.9', '1.0.0'), true);
    });

    test('إصدار مساوٍ أو أحدث ليس متأخراً', () {
      expect(svc.isBelowMinimum('1.1.0', '1.1.0'), false);
      expect(svc.isBelowMinimum('2.0.0', '1.1.0'), false);
    });

    test('يقارن patch بشكل صحيح', () {
      expect(svc.isBelowMinimum('1.0.5', '1.0.10'), true);
      expect(svc.isBelowMinimum('1.0.10', '1.0.5'), false);
    });
  });
}
