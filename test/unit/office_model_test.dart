import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/office_model.dart';

void main() {
  group('OfficeModel — approvalStatus (بند 3-أ-4)', () {
    test('الافتراضي pending عند عدم التحديد', () {
      const office = OfficeModel(officeId: 'o1', name: 'مكتب تجريبي', ownerAdminUid: 'u1');
      expect(office.approvalStatus, OfficeApprovalStatus.pending);
    });

    test('approvalStatus منفصل تماماً عن subscriptionStatus', () {
      const office = OfficeModel(
        officeId: 'o1',
        name: 'مكتب تجريبي',
        ownerAdminUid: 'u1',
        approvalStatus: OfficeApprovalStatus.approved,
        subscriptionStatus: SubscriptionStatus.gracePeriod,
      );
      final map = office.toMap();
      expect(map['approvalStatus'], 'approved');
      expect(map['subscriptionStatus'], 'gracePeriod');
    });
  });
}
