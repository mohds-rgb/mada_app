import '../models/admin_settings_model.dart';
import '../models/vehicle_category.dart';

/// حاسبة الأجرة (بند 8-المرحلة 1، 14). دالة نقية سهلة الاختبار — لا تلمس
/// أي حالة UI أو شبكة.
class FareCalculator {
  const FareCalculator(this._settings);

  final AdminSettingsModel _settings;

  /// السعر النهائي مقرَّباً لأقرب 500 (وحدة نقدية محلية) لسهولة الدفع النقدي.
  double estimateFare({
    required double distanceKm,
    required double durationMin,
    required VehicleCategory category,
  }) {
    final raw = (_settings.baseFare + (_settings.perKmRate * distanceKm) + (_settings.perMinRate * durationMin)) *
        _settings.surgeMultiplier *
        category.multiplier(_settings);
    return _roundToNearest(raw, 500);
  }

  double _roundToNearest(double value, double step) => (value / step).round() * step;
}
