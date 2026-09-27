import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/router/route_paths.dart';
import '../../shared/widgets/mada_primary_button.dart';

/// الشروط والأحكام وسياسة الخصوصية — موافقة إلزامية + طلب صلاحية GPS
/// إلزامياً كجزء من نفس الخطوة (بند 3-أ-1).
///
/// ⚠️ النص أدناه **مؤقت قابل للاستبدال** (بموافقتك الصريحة بالمرحلة 0.5) —
/// يُستبدَل بالنص النهائي الذي تعتمده أنت (owner-authored، بند 13-هـ) متى
/// جهّزته، بدون أي تعديل آخر بمنطق الشاشة.
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _agreed = false;
  bool _isProcessing = false;

  static const _termsSeenKey = 'terms_agreed';

  static const _tempTermsText = '''
هذا نص مؤقت للشروط والأحكام وسياسة الخصوصية لتطبيق "مدى" (MADA)، المملوك
والمُشغَّل بالكامل من قبل M&M TECH — يُستبدَل بالنص النهائي المعتمد لاحقاً.

باستخدامك التطبيق، أنت توافق على:
• جمع بيانات موقعك الجغرافي (GPS) أثناء استخدام خدمات الرحلات والتوصيل
  والتأجير، لتوفير الخدمة الأساسية (مطابقة السائقين، تتبع الرحلة، حساب
  المسافة والسعر).
• جمع بيانات حسابك الأساسية (البريد الإلكتروني، رقم الهاتف الاختياري،
  الاسم) لغرض إدارة حسابك وتقديم الدعم.
• استخدام بياناتك فقط ضمن نطاق تشغيل خدمة "مدى" — لا تُباع بياناتك لأي
  طرف ثالث.
• حقك بطلب حذف حسابك وبياناتك في أي وقت من الملف الشخصي.

الاستخدام مشروط بموافقتك الصريحة أدناه على منح صلاحية الموقع الجغرافي
(GPS)، وهي ضرورية لعمل التطبيق الأساسي ولا يمكن تجاوزها.
''';

  Future<void> _onAgreeAndContinue() async {
    if (!_agreed || _isProcessing) return;
    setState(() => _isProcessing = true);

    // طلب صلاحية GPS إلزامياً كجزء من نفس خطوة الموافقة (بند 3-أ-1).
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!mounted) return;

    if (permission == LocationPermission.deniedForever || !serviceEnabled) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('صلاحية الموقع مطلوبة'),
          content: const Text(
            'تطبيق مدى يحتاج صلاحية الموقع الجغرافي للعمل بشكل صحيح (طلب '
            'الرحلات، التتبع اللحظي). يمكنك المتابعة الآن وتفعيلها لاحقاً '
            'من إعدادات الجهاز عند الحاجة الفعلية.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً'))],
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsSeenKey, true);

    if (!mounted) return;
    setState(() => _isProcessing = false);
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الشروط والأحكام وسياسة الخصوصية')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(_tempTermsText, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('أوافق على الشروط والأحكام وسياسة الخصوصية، بما فيها استخدام GPS'),
                  ),
                  const SizedBox(height: 8),
                  MadaPrimaryButton(
                    label: 'متابعة',
                    isLoading: _isProcessing,
                    onPressed: _agreed ? _onAgreeAndContinue : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
