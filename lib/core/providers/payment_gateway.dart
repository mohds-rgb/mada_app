/// واجهة الدفع القابلة للتبديل (بند 5).
abstract class PaymentGateway {
  String get id;
  Future<bool> charge({required String userId, required double amount, required String referenceId});
}

/// ============ النشط الآن ============
/// دفع نقدي مباشر (عميل↔سائق، أو مكتب↔المنصة). لا معالجة إلكترونية فعلية؛
/// يُستخدم فقط لتوثيق طريقة الدفع المختارة بالطلب/الحجز.
class CashGateway implements PaymentGateway {
  const CashGateway();

  @override
  String get id => 'cash';

  @override
  Future<bool> charge({required String userId, required double amount, required String referenceId}) async {
    // لا عملية إلكترونية — يُسجَّل فقط أن طريقة الدفع نقدية بمستند الطلب/الحجز.
    return true;
  }
}

/// ============ Stub جاهز، منفذ واحد — يُربَط بنهاية المشروع (بند 5، 8 المرحلة 5) ============
class ShamCashGateway implements PaymentGateway {
  const ShamCashGateway();

  @override
  String get id => 'sham_cash';

  @override
  Future<bool> charge({required String userId, required double amount, required String referenceId}) {
    throw UnsupportedError('ShamCashGateway غير مربوط بعد — يُفعَّل بالمرحلة 5 (بند 8، 15)');
  }
}

/// نقطة تبديل المزوّد النشط — سطر واحد فقط.
const PaymentGateway activePaymentGateway = CashGateway();
