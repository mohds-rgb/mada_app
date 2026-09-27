import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sign_out_button.dart';
import 'ride_request/location_picker_screen.dart';
import 'ride_request/fare_estimate_screen.dart';
import 'rental/rental_browse_screen.dart';

/// الرئيسية — "أين تريد الذهاب؟" (بند 3-أ-4، 8-المرحلة 1).
/// ⚠️ خيارات الطلب الفعلية (رحلة/تأجير/توصيل) تُبنى بالمرحلة القادمة
/// (1.1 المقترحة) — هذه الشاشة تثبت التوجيه والدخول الكاملين الآن.
class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded, color: AppColors.gold, size: 40),
            const SizedBox(height: 12),
            Text('$feature قيد الإنشاء بالمرحلة القادمة', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _startRideRequest(BuildContext context) async {
    final pickup = await Navigator.push<LocationPickResult>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen(title: 'نقطة الانطلاق')),
    );
    if (pickup == null || !context.mounted) return;

    final destination = await Navigator.push<LocationPickResult>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(title: 'الوجهة', initialPoint: pickup.point)),
    );
    if (destination == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FareEstimateScreen(pickup: pickup, destination: destination)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أين تريد الذهاب؟'), actions: const [SignOutButton()]),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _HomeOptionCard(emoji: '🚕', label: 'رحلة', onTap: () => _startRideRequest(context)),
            _HomeOptionCard(
              emoji: '🚗',
              label: 'تأجير',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentalBrowseScreen())),
            ),
            _HomeOptionCard(emoji: '📦', label: 'توصيل طرود', onTap: () => _comingSoon(context, 'توصيل الطرود')),
            _HomeOptionCard(emoji: '⭐', label: 'المفضلة', onTap: () => _comingSoon(context, 'الأماكن المفضلة')),
          ],
        ),
      ),
    );
  }
}

class _HomeOptionCard extends StatelessWidget {
  const _HomeOptionCard({required this.emoji, required this.label, required this.onTap});

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
