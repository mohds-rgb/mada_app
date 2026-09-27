import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بوابة PIN محلية إضافية لدخول المالك (بند 8-المرحلة 4: "تحقق ثنائي إضافي
/// (PIN محلي)"). ⚠️ هذه بوابة راحة على مستوى الجهاز فقط لمنع نظرة عابرة
/// (shoulder surfing) على جهاز مشترك — **ليست بديلاً أمنياً** عن تسجيل
/// الدخول الفعلي (Email Link + Custom Claim owner، غير القابل للتزوير من
/// العميل). يُعاد التحقق بكل إعادة تشغيل للتطبيق (isVerified يبدأ false
/// دوماً)، ويُخزَّن رمز PIN محلياً عبر SharedPreferences (نص عادي — قيد
/// موثَّق، ترقية لاحقة ممكنة لـflutter_secure_storage عند الحاجة).
class PinGateNotifier extends ChangeNotifier {
  PinGateNotifier() {
    _load();
  }

  static const _pinKey = 'owner_pin_code';

  bool _isReady = false;
  bool _hasPinSet = false;
  bool _isVerified = false;

  bool get isReady => _isReady;
  bool get hasPinSet => _hasPinSet;
  bool get isVerified => _isVerified;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasPinSet = prefs.getString(_pinKey) != null;
    _isReady = true;
    notifyListeners();
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    _hasPinSet = true;
    _isVerified = true;
    notifyListeners();
  }

  Future<bool> verify(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_pinKey);
    final ok = saved != null && saved == pin;
    if (ok) {
      _isVerified = true;
      notifyListeners();
    }
    return ok;
  }

  /// يُستدعى عند تسجيل الخروج — يمنع تجاوز القفل بإعادة دخول سريعة بلا PIN.
  void reset() {
    _isVerified = false;
    notifyListeners();
  }
}
