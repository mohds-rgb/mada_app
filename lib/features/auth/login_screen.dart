import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/otp_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/mada_logo.dart';
import '../../shared/widgets/mada_primary_button.dart';

/// شاشة دخول موحّدة واحدة (تسجيل دخول أو إنشاء حساب) عبر EmailOtpProvider
/// (بند 3-أ-2، 6). بعد نجاح تسجيل الدخول، GoRouter (app_router.dart) يتكفّل
/// تلقائياً بالتوجيه الصحيح (شاشة اختيار الدور لمستخدم جديد، أو واجهته إن كان عائداً).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginStep { enterEmail, linkSent }

class _LoginScreenState extends State<LoginScreen> {
  static const _pendingEmailKey = 'pending_login_email';

  final _emailController = TextEditingController();
  final _linkController = TextEditingController();
  _LoginStep _step = _LoginStep.enterEmail;
  bool _isLoading = false;
  String? _error;

  bool get _isValidEmail => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim());

  Future<void> _sendLink() async {
    if (!_isValidEmail || _isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim();
      await activeOtpProvider.sendLoginLink(identifier: email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingEmailKey, email);
      if (!mounted) return;
      setState(() {
        _step = _LoginStep.linkSent;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'تعذّر إرسال رابط الدخول. تحقق من اتصالك بالإنترنت وحاول مجدداً.';
      });
    }
  }

  Future<void> _confirmLink() async {
    final link = _linkController.text.trim();
    if (link.isEmpty || _isLoading) return;

    if (!activeOtpProvider.isValidLoginLink(link)) {
      setState(() => _error = 'الرابط الذي أدخلته غير صالح — تأكد من نسخه كاملاً من البريد.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_pendingEmailKey) ?? _emailController.text.trim();
      await activeOtpProvider.completeSignIn(identifier: email, link: link);
      // نجاح تسجيل الدخول → AuthSessionNotifier يلتقط التغيير تلقائياً،
      // وGoRouter redirect يوجّه المستخدم بلا أي تنقّل يدوي هنا.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'تعذّر إكمال تسجيل الدخول. تأكد أن الرابط لم تنتهِ صلاحيته وحاول مجدداً.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: MadaLogo(size: 80)),
              const SizedBox(height: 32),
              Text(
                _step == _LoginStep.enterEmail ? 'تسجيل الدخول' : 'تحقق من بريدك',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (_step == _LoginStep.enterEmail) ..._buildEmailStep() else ..._buildLinkStep(),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEmailStep() {
    return [
      Text(
        'أدخل بريدك الإلكتروني وسنرسل لك رابط دخول آمن — بلا كلمة مرور.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.center,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(hintText: 'you@example.com'),
      ),
      const SizedBox(height: 16),
      MadaPrimaryButton(
        label: 'إرسال رابط الدخول',
        isLoading: _isLoading,
        onPressed: _isValidEmail ? _sendLink : null,
      ),
    ];
  }

  List<Widget> _buildLinkStep() {
    return [
      Text(
        'أرسلنا رابط دخول إلى ${_emailController.text.trim()}.\n'
        'افتح بريدك، انسخ الرابط كاملاً، والصقه هنا للمتابعة.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _linkController,
        textAlign: TextAlign.center,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'الصق رابط الدخول هنا'),
      ),
      const SizedBox(height: 16),
      MadaPrimaryButton(label: 'تأكيد الدخول', isLoading: _isLoading, onPressed: _confirmLink),
      TextButton(
        onPressed: _isLoading ? null : () => setState(() => _step = _LoginStep.enterEmail),
        child: const Text('استخدام بريد آخر'),
      ),
    ];
  }
}
