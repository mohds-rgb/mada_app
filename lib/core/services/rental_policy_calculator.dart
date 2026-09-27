/// سياسة الإلغاء والغرامات للتأجير (بند 8-المرحلة 3، 14) — دوال نقية
/// سهلة الاختبار، لا تلمس أي حالة UI أو شبكة.
class RentalPolicyCalculator {
  const RentalPolicyCalculator();

  /// نسبة استرداد العربون حسب المهلة الزمنية قبل موعد الاستلام (startDate):
  /// ≥48 ساعة: استرداد كامل (100%). ≥24 ساعة: 50%. أقل من 24 ساعة: صفر.
  double refundPercentage({required DateTime now, required DateTime startDate}) {
    final hoursUntilStart = startDate.difference(now).inHours;
    if (hoursUntilStart >= 48) return 1.0;
    if (hoursUntilStart >= 24) return 0.5;
    return 0.0;
  }

  double refundAmount({required DateTime now, required DateTime startDate, required double depositAmount}) {
    return depositAmount * refundPercentage(now: now, startDate: startDate);
  }

  /// غرامة تأخير الإرجاع: عدد الساعات المتأخرة (مقرَّبة للأعلى) × السعر
  /// بالساعة (adminSettings.lateFeePerHour). صفر إن لم يتأخر الإرجاع.
  double lateFee({required DateTime actualReturnTime, required DateTime scheduledEndDate, required double lateFeePerHour}) {
    if (!actualReturnTime.isAfter(scheduledEndDate)) return 0;
    final lateDuration = actualReturnTime.difference(scheduledEndDate);
    final lateHours = (lateDuration.inMinutes / 60).ceil();
    return lateHours * lateFeePerHour;
  }
}
