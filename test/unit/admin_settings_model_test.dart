import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/admin_settings_model.dart';

void main() {
  group('AdminSettingsModel — القيم الافتراضية (بند 8-المرحلة 0.5)', () {
    test('تردد تحديث الموقع الافتراضي 20 ثانية لا 10 (الحساب المُصحَّح)', () {
      const settings = AdminSettingsModel();
      expect(settings.locationUpdateIntervalSec, 20);
    });

    test('وضع الطوارئ يرفع التردد لـ30 ثانية (بند 17-أ)', () {
      const settings = AdminSettingsModel();
      expect(settings.emergencyModeIntervalSec, 30);
    });

    test('حد أقصى معامل الذروة متحفظ (1.5×) لسوق درعا (بند 14)', () {
      const settings = AdminSettingsModel();
      expect(settings.maxSurgeMultiplier, 1.5);
    });

    test('toMap/fromMap يحافظان على القيم دون فقدان بيانات', () {
      const settings = AdminSettingsModel(commissionPercentage: 20, maxSurgeMultiplier: 1.8);
      final map = settings.toMap();
      final restored = AdminSettingsModel.fromMap(map);
      expect(restored.commissionPercentage, 20);
      expect(restored.maxSurgeMultiplier, 1.8);
    });
  });
}
