import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/models/admin_settings_model.dart';
import '../../../core/repositories/admin_settings_repository.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// إعدادات المنصة الموحَّدة — يُحرِّر مستند adminSettings/global مباشرة
/// (بند 8-المرحلة 4-ج/هـ، 21). يُفعِّل فعلياً كل الحقول الجاهزة بالنموذج
/// منذ المرحلة 0 (عمولة، تسعير، ذروة، اشتراك...) من واجهة حقيقية لأول مرة.
class PlatformSettingsScreen extends StatefulWidget {
  const PlatformSettingsScreen({super.key});

  @override
  State<PlatformSettingsScreen> createState() => _PlatformSettingsScreenState();
}

class _PlatformSettingsScreenState extends State<PlatformSettingsScreen> {
  AdminSettingsModel? _settings;
  bool _isSaving = false;

  final _controllers = <String, TextEditingController>{};
  bool _serviceEnabled = true;
  bool _emergencyMode = false;
  late TextEditingController _announcementController;

  @override
  void initState() {
    super.initState();
    _announcementController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final settings = await const AdminSettingsRepository().fetch();
    _controllers.addAll({
      'commissionPercentage': TextEditingController(text: settings.commissionPercentage.toString()),
      'baseFare': TextEditingController(text: settings.baseFare.toString()),
      'perKmRate': TextEditingController(text: settings.perKmRate.toString()),
      'perMinRate': TextEditingController(text: settings.perMinRate.toString()),
      'deliveryBaseFare': TextEditingController(text: settings.deliveryBaseFare.toString()),
      'surgeMultiplier': TextEditingController(text: settings.surgeMultiplier.toString()),
      'maxSurgeMultiplier': TextEditingController(text: settings.maxSurgeMultiplier.toString()),
      'searchRadiusKm': TextEditingController(text: settings.searchRadiusKm.toString()),
      'cancellationGracePeriodMin': TextEditingController(text: settings.cancellationGracePeriodMin.toString()),
      'noShowFee': TextEditingController(text: settings.noShowFee.toString()),
      'subscriptionMonthlyFee': TextEditingController(text: settings.subscriptionMonthlyFee.toString()),
      'subscriptionGracePeriodDays': TextEditingController(text: settings.subscriptionGracePeriodDays.toString()),
      'lateFeePerHour': TextEditingController(text: settings.lateFeePerHour.toString()),
      'depositPercentage': TextEditingController(text: settings.depositPercentage.toString()),
      'callCenterNumbers': TextEditingController(text: settings.callCenterNumbers.join(', ')),
      'minSupportedVersion': TextEditingController(text: settings.minSupportedVersion),
    });
    _announcementController.text = settings.announcement ?? '';
    setState(() {
      _settings = settings;
      _serviceEnabled = settings.isServiceEnabled;
      _emergencyMode = settings.emergencyModeActive;
    });
  }

  double _num(String key) => double.tryParse(_controllers[key]!.text) ?? 0;
  int _int(String key) => int.tryParse(_controllers[key]!.text) ?? 0;

  Future<void> _save() async {
    if (_settings == null || _isSaving) return;
    setState(() => _isSaving = true);

    final updated = AdminSettingsModel(
      commissionPercentage: _num('commissionPercentage'),
      baseFare: _num('baseFare'),
      perKmRate: _num('perKmRate'),
      perMinRate: _num('perMinRate'),
      deliveryBaseFare: _num('deliveryBaseFare'),
      surgeMultiplier: _num('surgeMultiplier'),
      maxSurgeMultiplier: _num('maxSurgeMultiplier'),
      searchRadiusKm: _num('searchRadiusKm'),
      cancellationGracePeriodMin: _int('cancellationGracePeriodMin'),
      noShowFee: _num('noShowFee'),
      subscriptionMonthlyFee: _num('subscriptionMonthlyFee'),
      subscriptionGracePeriodDays: _int('subscriptionGracePeriodDays'),
      lateFeePerHour: _num('lateFeePerHour'),
      depositPercentage: _num('depositPercentage'),
      callCenterNumbers: _controllers['callCenterNumbers']!.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      minSupportedVersion: _controllers['minSupportedVersion']!.text.trim(),
      isServiceEnabled: _serviceEnabled,
      emergencyModeActive: _emergencyMode,
      announcement: _announcementController.text.trim().isEmpty ? null : _announcementController.text.trim(),
      announcementUpdatedAt: _announcementController.text.trim().isEmpty ? null : DateTime.now(),
      // الحقول غير المعروضة بهذا النموذج تبقى بقيمها الحالية دون تغيير.
      economyMultiplier: _settings!.economyMultiplier,
      comfortMultiplier: _settings!.comfortMultiplier,
      premiumMultiplier: _settings!.premiumMultiplier,
      driverSearchTimeoutSec: _settings!.driverSearchTimeoutSec,
      driverSearchRadiusKm: _settings!.driverSearchRadiusKm,
      driverSearchExpansionSteps: _settings!.driverSearchExpansionSteps,
      locationUpdateIntervalSec: _settings!.locationUpdateIntervalSec,
      emergencyModeIntervalSec: _settings!.emergencyModeIntervalSec,
      referralMonthlyCap: _settings!.referralMonthlyCap,
      maxUnsettledDebt: _settings!.maxUnsettledDebt,
      surgeHours: _settings!.surgeHours,
    );

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.adminSettings)
          .doc(FirestoreCollections.adminSettingsDocId)
          .set(updated.toMap());
      await const AuditLogService().log(action: 'platformSettingsUpdated');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر الحفظ — حاول مجدداً')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _announcementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SwitchListTile(
          value: _serviceEnabled,
          onChanged: (v) => setState(() => _serviceEnabled = v),
          title: const Text('تشغيل الخدمة'),
          subtitle: const Text('إيقافها يمنع أي طلب رحلة/تأجير/توصيل جديد مؤقتاً'),
        ),
        SwitchListTile(
          value: _emergencyMode,
          onChanged: (v) => setState(() => _emergencyMode = v),
          title: const Text('وضع الطوارئ (تتبع كل 30 ثانية)'),
          subtitle: const Text('فعِّله عند اقتراب حصة Firestore المجانية (بند 8-0.5)'),
        ),
        const Divider(height: 32),
        _field('commissionPercentage', 'نسبة العمولة (%)'),
        _field('baseFare', 'الأجرة الأساسية'),
        _field('perKmRate', 'السعر لكل كم'),
        _field('perMinRate', 'السعر لكل دقيقة'),
        _field('deliveryBaseFare', 'أجرة توصيل الطرود الأساسية'),
        const Divider(height: 32),
        _field('surgeMultiplier', 'معامل الذروة الحالي'),
        _field('maxSurgeMultiplier', 'الحد الأقصى لمعامل الذروة'),
        const Divider(height: 32),
        _field('searchRadiusKm', 'نصف قطر البحث عن سائق (كم)'),
        _field('cancellationGracePeriodMin', 'مهلة الإلغاء المجاني (دقيقة)'),
        _field('noShowFee', 'رسوم عدم الحضور'),
        const Divider(height: 32),
        _field('subscriptionMonthlyFee', 'قيمة اشتراك المكتب الشهري'),
        _field('subscriptionGracePeriodDays', 'مهلة سماح الاشتراك (يوم)'),
        _field('lateFeePerHour', 'غرامة تأخير الإرجاع بالساعة'),
        _field('depositPercentage', 'نسبة العربون (%)'),
        const Divider(height: 32),
        _field('callCenterNumbers', 'أرقام الطوارئ/مركز الاتصال (مفصولة بفاصلة)'),
        _field('minSupportedVersion', 'الحد الأدنى لإصدار التطبيق (Force Update)'),
        const Divider(height: 32),
        TextField(
          controller: _announcementController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'إشعار جماعي (بانر داخل التطبيق لكل المستخدمين)'),
        ),
        const SizedBox(height: 24),
        MadaPrimaryButton(label: 'حفظ الإعدادات', isLoading: _isSaving, onPressed: _save),
      ],
    );
  }

  Widget _field(String key, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: _controllers[key], decoration: InputDecoration(labelText: label)),
      );
}
