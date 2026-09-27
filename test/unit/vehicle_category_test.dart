import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/admin_settings_model.dart';
import 'package:mada_app/core/models/vehicle_category.dart';

void main() {
  group('VehicleCategory (بند 8-المرحلة 1)', () {
    test('معاملات الفئات الافتراضية مطابقة للقرار الموثَّق', () {
      const settings = AdminSettingsModel();
      expect(VehicleCategory.economy.multiplier(settings), 1.0);
      expect(VehicleCategory.comfort.multiplier(settings), 1.3);
      expect(VehicleCategory.premium.multiplier(settings), 1.6);
    });

    test('التسميات العربية صحيحة', () {
      expect(VehicleCategory.economy.labelAr, 'اقتصادية');
      expect(VehicleCategory.comfort.labelAr, 'Comfort');
      expect(VehicleCategory.premium.labelAr, 'Premium');
    });
  });
}
