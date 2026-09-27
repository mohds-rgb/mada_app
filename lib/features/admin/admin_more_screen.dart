import 'package:flutter/material.dart';
import '../moderation/abusive_ratings_screen.dart';
import '../moderation/sos_monitoring_screen.dart';
import '../owner/management/drivers_management_screen.dart';
import '../owner/phone_orders/phone_order_screen.dart';
import '../owner/lost_items/lost_items_screen.dart';

class _MoreItem {
  const _MoreItem(this.icon, this.label, this.builder);
  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// المزيد — أدوات الأدمن التشغيلي (بند 8-المرحلة 4.5): اعتماد وثائق
/// السائقين فقط (بلا حظر)، الطلبات الهاتفية، التقييمات، المفقودات، SOS.
class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(Icons.sos_rounded, 'متابعة SOS', (_) => const SosMonitoringScreen()),
      _MoreItem(Icons.badge_outlined, 'اعتماد وثائق السائقين', (_) => const DriversManagementScreen(isOwner: false)),
      _MoreItem(Icons.phone_forwarded_outlined, 'طلب هاتفي', (_) => const PhoneOrderScreen()),
      _MoreItem(Icons.star_border_rounded, 'مراجعة التقييمات', (_) => const AbusiveRatingsScreen()),
      _MoreItem(Icons.search_off_rounded, 'المفقودات', (_) => const LostItemsScreen()),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          child: ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: item.builder)),
          ),
        );
      },
    );
  }
}
