import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/models/admin_settings_model.dart';
import 'package:mada_app/core/models/vehicle_category.dart';
import 'package:mada_app/core/services/fare_calculator.dart';

void main() {
  group('FareCalculator (بند 8-المرحلة 1، 14)', () {
    // الإعدادات الافتراضية: baseFare=2000, perKmRate=800, perMinRate=100.
    test('فئة اقتصادية، بلا ذروة: 5كم و10 دقائق', () {
      const calc = FareCalculator(AdminSettingsModel());
      // raw = 2000 + 800*5 + 100*10 = 2000+4000+1000 = 7000؛ ×1.0 economy ×1.0 surge = 7000
      final fare = calc.estimateFare(distanceKm: 5, durationMin: 10, category: VehicleCategory.economy);
      expect(fare, 7000);
    });

    test('فئة Comfort تضرب بمعامل 1.3', () {
      const calc = FareCalculator(AdminSettingsModel());
      final fare = calc.estimateFare(distanceKm: 5, durationMin: 10, category: VehicleCategory.comfort);
      // 7000 × 1.3 = 9100
      expect(fare, 9100);
    });

    test('فئة Premium تضرب بمعامل 1.6', () {
      const calc = FareCalculator(AdminSettingsModel());
      final fare = calc.estimateFare(distanceKm: 5, durationMin: 10, category: VehicleCategory.premium);
      // 7000 × 1.6 = 11200
      expect(fare, 11200);
    });

    test('تسعير الذروة (surgeMultiplier) يرفع السعر النسبي', () {
      const calc = FareCalculator(AdminSettingsModel(surgeMultiplier: 1.5));
      final fare = calc.estimateFare(distanceKm: 5, durationMin: 10, category: VehicleCategory.economy);
      // 7000 × 1.5 = 10500
      expect(fare, 10500);
    });

    test('التقريب لأقرب 500', () {
      const calc = FareCalculator(AdminSettingsModel());
      final fare = calc.estimateFare(distanceKm: 1.2, durationMin: 3, category: VehicleCategory.economy);
      expect(fare % 500, 0);
    });
  });
}
