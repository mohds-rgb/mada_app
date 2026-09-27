import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/version_check_service.dart';
import '../../core/theme/app_colors.dart';
import 'network_status_banner.dart';

/// يلفّ التطبيق بأكمله: يفرض التحديث الإجباري (بند 16) عند تقادم الإصدار،
/// ويعرض بانر الإشعار الجماعي القابل للإغلاق (بند 8-المرحلة 4-هـ — بديل
/// عملي بلا Cloud Functions، انظر PROJECT_STATE.md). يقرأ adminSettings/global
/// حيّاً فيعمل فوراً دون الحاجة لإعادة تشغيل التطبيق.
class PlatformGate extends StatefulWidget {
  const PlatformGate({super.key, required this.child});

  final Widget child;

  @override
  State<PlatformGate> createState() => _PlatformGateState();
}

class _PlatformGateState extends State<PlatformGate> {
  String? _dismissedAnnouncementKey;

  @override
  void initState() {
    super.initState();
    _loadDismissed();
  }

  Future<void> _loadDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _dismissedAnnouncementKey = prefs.getString('dismissed_announcement'));
  }

  Future<void> _dismiss(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dismissed_announcement', key);
    if (mounted) setState(() => _dismissedAnnouncementKey = key);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection(FirestoreCollections.adminSettings).doc(FirestoreCollections.adminSettingsDocId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        if (data == null) return widget.child; // لا إعدادات مستورَدة بعد — لا حجب افتراضياً.

        final minVersion = data['minSupportedVersion'] as String? ?? '1.0.0';
        final announcement = data['announcement'] as String?;
        final announcementTs = (data['announcementUpdatedAt'] as Timestamp?)?.millisecondsSinceEpoch.toString();

        return FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, pkgSnapshot) {
            final currentVersion = pkgSnapshot.data?.version ?? '1.0.0';
            final needsUpdate = const VersionCheckService().isBelowMinimum(currentVersion, minVersion);

            if (needsUpdate) {
              return _ForceUpdateScreen(minVersion: minVersion);
            }

            final showAnnouncement = announcement != null && announcement.isNotEmpty && announcementTs != _dismissedAnnouncementKey;

            return Column(
              children: [
                const NetworkStatusBanner(),
                if (showAnnouncement)
                  Material(
                    color: AppColors.gold,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.campaign_outlined, color: AppColors.navy),
                            const SizedBox(width: 10),
                            Expanded(child: Text(announcement, style: const TextStyle(color: AppColors.navy))),
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.navy, size: 18),
                              onPressed: () => _dismiss(announcementTs!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(child: widget.child),
              ],
            );
          },
        );
      },
    );
  }
}

class _ForceUpdateScreen extends StatelessWidget {
  const _ForceUpdateScreen({required this.minVersion});
  final String minVersion;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.navyDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update_alt_rounded, size: 56, color: AppColors.turquoise),
                const SizedBox(height: 20),
                const Text('يتوفر تحديث إلزامي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  'يرجى تحديث التطبيق إلى أحدث إصدار للمتابعة (الحد الأدنى المطلوب: $minVersion).',
                  style: const TextStyle(color: AppColors.textMutedDark),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
