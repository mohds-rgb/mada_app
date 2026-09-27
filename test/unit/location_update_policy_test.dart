import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/admin_settings_model.dart';
import 'package:mada_app/core/services/location_update_policy.dart';

void main() {
  group('LocationUpdatePolicy — حسابات الحصة المجانية (بند 8، المرحلة 0.5)', () {
    test('10 سيارات × 8 ساعات بتردد 20ث = 14,400 كتابة/يوم (ضمن الحصة)', () {
      const policy = LocationUpdatePolicy(AdminSettingsModel());
      expect(policy.currentIntervalSeconds, 20);
      expect(policy.estimatedDailyWrites(activeVehicles: 10), 14400);
      expect(policy.isApproachingFreeQuota(activeVehicles: 10), false);
    });

    test('وضع الطوارئ يرفع التردد لـ30ث فيخفض الكتابات لـ9,600 لـ10 سيارات', () {
      const policy = LocationUpdatePolicy(AdminSettingsModel(emergencyModeActive: true));
      expect(policy.currentIntervalSeconds, 30);
      expect(policy.estimatedDailyWrites(activeVehicles: 10), 9600);
    });

    test('بتردد 10ث الافتراضي (سيناريو مرفوض) — 10 سيارات تتجاوز الحصة كاملة', () {
      const policy = LocationUpdatePolicy(AdminSettingsModel(locationUpdateIntervalSec: 10));
      // 10 سيارات × 8 ساعات بتردد 10ث = 28,800 > 20,000 (الحصة اليومية كاملة)
      expect(policy.estimatedDailyWrites(activeVehicles: 10), 28800);
      expect(policy.isApproachingFreeQuota(activeVehicles: 10), true);
    });

    test('وضع توفير البيانات يفرض 30ث بصرف النظر عن وضع الطوارئ', () {
      const policy = LocationUpdatePolicy(AdminSettingsModel());
      expect(policy.intervalWithDataSaver(dataSaverEnabled: true), 30);
      expect(policy.intervalWithDataSaver(dataSaverEnabled: false), 20);
    });
  });
}
