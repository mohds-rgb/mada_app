import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mada_app/core/providers/pin_gate_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinGateNotifier (بند 8-المرحلة 4 — بوابة PIN محلية)', () {
    test('لا يوجد PIN محفوظ مبدئياً، وأول setPin يُفعِّل التحقق فوراً', () async {
      SharedPreferences.setMockInitialValues({});
      final gate = PinGateNotifier();
      await Future.delayed(Duration.zero); // انتظار _load()
      expect(gate.hasPinSet, false);
      expect(gate.isVerified, false);

      await gate.setPin('1234');
      expect(gate.hasPinSet, true);
      expect(gate.isVerified, true);
    });

    test('verify يعيد true فقط للرمز الصحيح، ولا يُفعِّل التحقق عند الخطأ', () async {
      SharedPreferences.setMockInitialValues({'owner_pin_code': '5678'});
      final gate = PinGateNotifier();
      await Future.delayed(Duration.zero);

      expect(await gate.verify('0000'), false);
      expect(gate.isVerified, false);

      expect(await gate.verify('5678'), true);
      expect(gate.isVerified, true);
    });

    test('reset() يُعيد isVerified لـfalse دون مسح الرمز المحفوظ', () async {
      SharedPreferences.setMockInitialValues({'owner_pin_code': '5678'});
      final gate = PinGateNotifier();
      await Future.delayed(Duration.zero);
      await gate.verify('5678');
      expect(gate.isVerified, true);

      gate.reset();
      expect(gate.isVerified, false);
      expect(gate.hasPinSet, true); // الرمز نفسه يبقى محفوظاً
    });
  });
}
