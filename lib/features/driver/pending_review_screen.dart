import 'package:flutter/material.dart';
import 'driver_registration_screen.dart';
import '../../shared/widgets/sign_out_button.dart';

/// "قيد المراجعة" — للسائق أو مكتب التأجير لحين اعتماد المالك (بند 3-أ-4).
///
/// ⚠️ قيد مؤقت موثَّق (PROJECT_STATE.md): لا توجد بعد لوحة مالك (المرحلة 4)
/// لاعتماد الطلبات من داخل التطبيق. الاعتماد حالياً يتم يدوياً من صاحب
/// المشروع عبر Firebase Console → Firestore → تعديل حقل status/approvalStatus
/// إلى 'approved' مباشرة على المستند المطابق — خطوة مؤقتة قابلة للإزالة
/// فور بناء لوحة المالك.
class PendingReviewScreen extends StatelessWidget {
  const PendingReviewScreen({super.key, required this.roleLabel, this.showCompleteDriverProfile = false});

  final String roleLabel;
  final bool showCompleteDriverProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قيد المراجعة'), actions: const [SignOutButton()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 56),
              const SizedBox(height: 20),
              Text('طلبك كـ$roleLabel قيد المراجعة', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'سيقوم فريق مدى بمراجعة طلبك واعتماده قريباً — سنُعلمك فور الموافقة.',
                textAlign: TextAlign.center,
              ),
              if (showCompleteDriverProfile) ...[
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverRegistrationScreen())),
                  child: const Text('أكمل بيانات الرخصة والمركبة'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
