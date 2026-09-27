import 'package:flutter_test/flutter_test.dart';
import 'package:mada_app/core/services/rental_policy_calculator.dart';

void main() {
  const calc = RentalPolicyCalculator();
  final now = DateTime(2026, 1, 10, 12, 0);

  group('RentalPolicyCalculator.refundPercentage (بند 8-المرحلة 3)', () {
    test('استرداد كامل قبل 48 ساعة أو أكثر', () {
      expect(calc.refundPercentage(now: now, startDate: now.add(const Duration(hours: 48))), 1.0);
      expect(calc.refundPercentage(now: now, startDate: now.add(const Duration(hours: 72))), 1.0);
    });

    test('استرداد 50% بين 24 و48 ساعة', () {
      expect(calc.refundPercentage(now: now, startDate: now.add(const Duration(hours: 24))), 0.5);
      expect(calc.refundPercentage(now: now, startDate: now.add(const Duration(hours: 47))), 0.5);
    });

    test('صفر استرداد أقل من 24 ساعة', () {
      expect(calc.refundPercentage(now: now, startDate: now.add(const Duration(hours: 23))), 0.0);
      expect(calc.refundPercentage(now: now, startDate: now), 0.0);
    });

    test('refundAmount يطبّق النسبة على العربون', () {
      final amount = calc.refundAmount(now: now, startDate: now.add(const Duration(hours: 48)), depositAmount: 40000);
      expect(amount, 40000);
      final half = calc.refundAmount(now: now, startDate: now.add(const Duration(hours: 30)), depositAmount: 40000);
      expect(half, 20000);
    });
  });

  group('RentalPolicyCalculator.lateFee', () {
    test('صفر عند الإرجاع في الموعد أو قبله', () {
      final scheduledEnd = now;
      expect(calc.lateFee(actualReturnTime: now, scheduledEndDate: scheduledEnd, lateFeePerHour: 5000), 0);
      expect(calc.lateFee(actualReturnTime: now.subtract(const Duration(hours: 1)), scheduledEndDate: scheduledEnd, lateFeePerHour: 5000), 0);
    });

    test('يُحسَب بالساعة مقرَّباً للأعلى', () {
      final scheduledEnd = now;
      // ساعة ونصف تأخير → تُقرَّب لساعتين
      final fee = calc.lateFee(actualReturnTime: now.add(const Duration(hours: 1, minutes: 30)), scheduledEndDate: scheduledEnd, lateFeePerHour: 5000);
      expect(fee, 10000);
    });
  });
}
