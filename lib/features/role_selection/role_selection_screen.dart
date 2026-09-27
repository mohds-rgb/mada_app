import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/device_fingerprint_service.dart';
import '../../core/theme/app_colors.dart';

/// "اختر دورك" — تظهر فوراً بعد إنشاء الحساب لأول مرة فقط (بند 3-أ-3).
/// owner/admin لا يظهران هنا أبداً (بند 3-ب) — يُمنحان حصراً عبر
/// admin_scripts/set_role.js (Custom Claims).
///
/// ⚠️ قيد مؤقت موثَّق: اختيار "سائق"/"مكتب تأجير" هنا ينشئ مستنداً أولياً
/// بحالة "قيد المراجعة" فقط — نموذج التسجيل الكامل (رخصة، بيانات السيارة،
/// صور المكتب) يُبنى بالمرحلتين 2 و3 المخصصتين لكل دور، تماشياً مع تجزئة
/// المراحل الأصلية (بند 8). لا يمنع هذا مسار التوجيه من العمل كاملاً الآن.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isSubmitting = false;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  String get _email => FirebaseAuth.instance.currentUser!.email ?? '';

  /// يتحقق أن جهاز التسجيل غير محظور (منع الالتفاف بحساب جديد على نفس
  /// الجهاز، بند 12-هـ، 13-د)، ويُعيد بصمة الجهاز لتُخزَّن بالحساب الجديد.
  /// عودة null تعني تعذّر القراءة (منصة غير مدعومة) — لا يوقف التسجيل أبداً.
  Future<String?> _checkDeviceAndGetFingerprint() async {
    final fingerprint = await const DeviceFingerprintService().currentFingerprint();
    if (fingerprint == null) return null;

    final banDoc = await FirebaseFirestore.instance.collection(FirestoreCollections.bannedDevices).doc(fingerprint).get();
    if (banDoc.exists) {
      throw Exception('هذا الجهاز محظور من استخدام مدى.');
    }
    return fingerprint;
  }

  Future<void> _selectCustomer() async {
    await _submit(() async {
      final fingerprint = await _checkDeviceAndGetFingerprint();
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(_uid);
      batch.set(userRef, {
        'role': 'customer',
        'email': _email,
        'accountStatus': 'active',
        'preferredLanguage': 'ar',
        'isSimpleMode': false,
        'loyaltyPoints': 0,
        'deviceFingerprint': fingerprint,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    });
  }

  Future<void> _selectDriver() async {
    await _submit(() async {
      final fingerprint = await _checkDeviceAndGetFingerprint();
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(_uid);
      final driverRef = FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(_uid);
      batch.set(userRef, {
        'role': 'driver',
        'email': _email,
        'accountStatus': 'active',
        'preferredLanguage': 'ar',
        'deviceFingerprint': fingerprint,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(driverRef, {
        'fullName': '',
        'licenseNumber': '',
        'licensePhotoUrl': '',
        'vehicleType': '',
        'vehiclePlate': '',
        'status': 'pending',
        'walletBalance': 0,
        'isFemale': false,
        'selfieCheckStatus': 'notRequired',
        'rating': 5.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    });
  }

  Future<void> _selectOffice() async {
    final officeName = await _promptOfficeName();
    if (officeName == null || officeName.trim().isEmpty) return;

    await _submit(() async {
      final fingerprint = await _checkDeviceAndGetFingerprint();
      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(_uid);
      final officeRef = FirebaseFirestore.instance.collection(FirestoreCollections.offices).doc(_uid);
      batch.set(userRef, {
        'role': 'officeAdmin',
        'email': _email,
        'accountStatus': 'active',
        'preferredLanguage': 'ar',
        'deviceFingerprint': fingerprint,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(officeRef, {
        'name': officeName.trim(),
        'ownerAdminUid': _uid,
        'approvalStatus': 'pending',
        'plan': 'standard',
        'subscriptionStatus': 'active',
        'paymentMethod': 'cash',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    });
  }

  Future<String?> _promptOfficeName() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اسم مكتب التأجير'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'مثال: مكتب الحوراني للتأجير')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('متابعة')),
        ],
      ),
    );
  }

  Future<void> _submit(Future<void> Function() action) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await action();
      // نجاح الكتابة → AuthSessionNotifier (يستمع لنفس المستند) يلتقط
      // الدور الجديد تلقائياً، وGoRouter يوجّه المستخدم بلا أي تنقّل يدوي هنا.
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('محظور') ? 'هذا الجهاز محظور من استخدام مدى.' : 'تعذّر حفظ اختيارك — حاول مجدداً.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر دورك')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text('كيف تريد استخدام مدى؟', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    _RoleCard(
                      emoji: '🚕',
                      title: 'عميل',
                      subtitle: 'اطلب رحلة، استأجر سيارة، أو أرسل طرداً',
                      onTap: _selectCustomer,
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      emoji: '🚗',
                      title: 'سائق',
                      subtitle: 'انضم كسائق ووفّر رحلات وتوصيل (يخضع لاعتماد الإدارة)',
                      onTap: _selectDriver,
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      emoji: '🏢',
                      title: 'مكتب تأجير',
                      subtitle: 'أدر أسطول سياراتك وحجوزات مكتبك (يخضع لاعتماد الإدارة)',
                      onTap: _selectOffice,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.emoji, required this.title, required this.subtitle, required this.onTap});

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMutedLight)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
