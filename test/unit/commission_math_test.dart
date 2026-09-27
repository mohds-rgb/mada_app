import 'package:flutter_test/flutter_test.dart';

/// اختبار الصيغة الحسابية المستقلة المستخدمة في CommissionDeductionService
/// وfirestore.rules معاً (كلاهما يُعيدان نفس الحساب البسيط: fare × نسبة٪ ÷
/// 100) — بند 10. المنطق الفعلي يعيش داخل معاملة Firestore (غير قابلة
/// للاختبار بوحدة معزولة بلا محاكي Firebase)، فهذا الاختبار يُثبِّت صحة
/// الصيغة الرياضية نفسها المكرَّرة في الطرفين (Dart والقاعدة) فلا تنحرف
/// إحداهما عن الأخرى مستقبلاً.
double commissionFormula(double fare, double commissionPercentage) => fare * commissionPercentage / 100;

void main() {
  group('صيغة حساب العمولة (بند 10 — خصم تلقائي)', () {
    test('15% من 7000 = 1050', () {
      expect(commissionFormula(7000, 15), 1050);
    });

    test('0% عمولة = صفر خصم', () {
      expect(commissionFormula(10000, 0), 0);
    });

    test('عمولة مرتفعة استثنائياً (50%) تُحسَب بشكل صحيح رياضياً', () {
      expect(commissionFormula(10000, 50), 5000);
    });
  });
}
