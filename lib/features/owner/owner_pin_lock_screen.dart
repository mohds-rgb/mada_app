import 'package:flutter/material.dart';
import '../../core/providers/pin_gate_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/mada_logo.dart';
import '../../shared/widgets/mada_primary_button.dart';
import '../../shared/widgets/sign_out_button.dart';

/// قفل PIN محلي إضافي لدخول المالك (بند 8-المرحلة 4). أول استخدام: تعيين
/// رمز جديد. لاحقاً: إدخال الرمز المحفوظ.
class OwnerPinLockScreen extends StatefulWidget {
  const OwnerPinLockScreen({super.key, required this.pinGate});

  final PinGateNotifier pinGate;

  @override
  State<OwnerPinLockScreen> createState() => _OwnerPinLockScreenState();
}

class _OwnerPinLockScreenState extends State<OwnerPinLockScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'الرمز يجب أن يكون 4 أرقام على الأقل');
      return;
    }

    if (!widget.pinGate.hasPinSet) {
      if (pin != _confirmController.text.trim()) {
        setState(() => _error = 'الرمزان غير متطابقين');
        return;
      }
      await widget.pinGate.setPin(pin);
      // pinGate جزء من refreshListenable لـGoRouter — التوجيه للوحة
      // المالك يحدث تلقائياً فور notifyListeners داخل setPin().
    } else {
      final ok = await widget.pinGate.verify(pin);
      if (!ok && mounted) setState(() => _error = 'رمز غير صحيح');
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pinGate.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isFirstTime = !widget.pinGate.hasPinSet;

    return Scaffold(
      appBar: AppBar(title: const Text('رمز الدخول'), actions: const [SignOutButton()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MadaLogo(size: 64),
              const SizedBox(height: 24),
              Text(
                isFirstTime ? 'عيّن رمز PIN لحماية لوحة المالك على هذا الجهاز' : 'أدخل رمز PIN',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(counterText: ''),
              ),
              if (isFirstTime) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: 'تأكيد الرمز', counterText: ''),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.error)),
              ],
              const SizedBox(height: 20),
              MadaPrimaryButton(label: isFirstTime ? 'تعيين الرمز' : 'دخول', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
