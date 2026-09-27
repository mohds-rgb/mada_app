import '../models/admin_settings_model.dart';

/// سياسة تردد تحديث الموقع اللحظي — بند 8، المرحلة 0.5.
/// يستهلكها لاحقاً تتبع السائق (المرحلة 2) وتتبع أسطول المكتب (المرحلة 3)
/// عبر vehicleLocations — بدل كتابة الرقم مباشرة بكل مكان.
///
/// الحساب المُصحَّح (موثَّق بالكامل في PROJECT_STATE.md):
/// - Firestore/Spark = 20,000 كتابة/يوم مجاناً.
/// - بتردد 10ث: سيارة واحدة×8 ساعات = 2,880 كتابة/يوم؛ 10 سيارات = 28,800
///   كتابة/يوم من التتبع وحده — يتجاوز الحصة كاملة بمفرده.
/// - بتردد 20ث (الافتراضي المعتمد): 10 سيارات = 14,400 كتابة/يوم — ضمن
///   الحصة مع هامش ~28% لبقية كتابات التطبيق.
/// - "وضع الطوارئ" (adminSettings.emergencyModeActive=true، يُفعَّل يدوياً
///   من لوحة المالك بالمرحلة 4 عند ملاحظة اقتراب الحصة من Firebase Console/
///   GCP Billing — لا توجد Cloud Functions لقياسها تلقائياً على Spark):
///   يرفع التردد لـ30 ثانية → 10 سيارات = 9,600 كتابة/يوم فقط.
class LocationUpdatePolicy {
  const LocationUpdatePolicy(this._settings);

  final AdminSettingsModel _settings;

  /// التردد الحالي الواجب استخدامه (بالثواني) حسب حالة وضع الطوارئ.
  int get currentIntervalSeconds =>
      _settings.emergencyModeActive ? _settings.emergencyModeIntervalSec : _settings.locationUpdateIntervalSec;

  /// وضع توفير البيانات (بند 8-المرحلة 2): يرفع الفتحة الزمنية يدوياً من
  /// إعدادات السائق نفسه إلى 30 ثانية، بصرف النظر عن وضع الطوارئ العام.
  int intervalWithDataSaver({required bool dataSaverEnabled}) {
    if (dataSaverEnabled) return 30;
    return currentIntervalSeconds;
  }

  /// تقدير الكتابات اليومية المتوقعة لعدد مركبات معيّن، لعدد ساعات اتصال
  /// معيّنة — يُستخدم بلوحة المالك لعرض استهلاك الحصة تقديرياً (المرحلة 4).
  int estimatedDailyWrites({required int activeVehicles, int hoursOnlinePerVehicle = 8}) {
    final writesPerVehicle = (hoursOnlinePerVehicle * 3600) ~/ currentIntervalSeconds;
    return writesPerVehicle * activeVehicles;
  }

  /// تنبيه بسيط: هل التقدير الحالي يتجاوز نسبة معينة من الحصة اليومية
  /// المجانية (20,000 كتابة)؟ يُستخدم لعرض تحذير استباقي بلوحة المالك.
  bool isApproachingFreeQuota({required int activeVehicles, int hoursOnlinePerVehicle = 8, double thresholdRatio = 0.7}) {
    const dailyFreeWriteQuota = 20000;
    final estimated = estimatedDailyWrites(activeVehicles: activeVehicles, hoursOnlinePerVehicle: hoursOnlinePerVehicle);
    return estimated >= dailyFreeWriteQuota * thresholdRatio;
  }
}
