import 'admin_settings_model.dart';

/// فئات الرحلة (بند 8-المرحلة 1): اقتصادية/Comfort/Premium.
enum VehicleCategory { economy, comfort, premium }

extension VehicleCategoryX on VehicleCategory {
  String get labelAr {
    switch (this) {
      case VehicleCategory.economy:
        return 'اقتصادية';
      case VehicleCategory.comfort:
        return 'Comfort';
      case VehicleCategory.premium:
        return 'Premium';
    }
  }

  double multiplier(AdminSettingsModel settings) {
    switch (this) {
      case VehicleCategory.economy:
        return settings.economyMultiplier;
      case VehicleCategory.comfort:
        return settings.comfortMultiplier;
      case VehicleCategory.premium:
        return settings.premiumMultiplier;
    }
  }
}
