import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/user_role.dart';

void main() {
  group('UserRole parsing (بند 3-د)', () {
    test('يحوّل نصوص الأدوار المعروفة بشكل صحيح', () {
      expect('customer'.toUserRole(), UserRole.customer);
      expect('driver'.toUserRole(), UserRole.driver);
      expect('officeAdmin'.toUserRole(), UserRole.officeAdmin);
      expect('owner'.toUserRole(), UserRole.owner);
      expect('admin'.toUserRole(), UserRole.admin);
    });

    test('أي قيمة غير معروفة أو null تُعامَل كـ unknown (آمن افتراضياً)', () {
      expect(null.toUserRole(), UserRole.unknown);
      expect('hacker'.toUserRole(), UserRole.unknown);
    });

    test('isOwnerOrAdmin صحيح فقط لـ owner/admin', () {
      expect(UserRole.owner.isOwnerOrAdmin, true);
      expect(UserRole.admin.isOwnerOrAdmin, true);
      expect(UserRole.customer.isOwnerOrAdmin, false);
      expect(UserRole.driver.isOwnerOrAdmin, false);
    });
  });
}
