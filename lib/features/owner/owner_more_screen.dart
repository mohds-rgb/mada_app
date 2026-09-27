import 'package:flutter/material.dart';
import 'backup/backup_export_screen.dart';
import 'business/business_contracts_screen.dart';
import 'finance/owner_finance_root.dart';
import 'fleet_map/owner_fleet_map_screen.dart';
import 'lost_items/lost_items_screen.dart';
import 'phone_orders/phone_order_screen.dart';
import 'promo/promo_codes_screen.dart';
import 'settings/platform_settings_screen.dart';
import '../moderation/abusive_ratings_screen.dart';
import '../moderation/reports_management_screen.dart';
import '../moderation/sos_monitoring_screen.dart';

class _MoreItem {
  const _MoreItem(this.icon, this.label, this.builder);
  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// المزيد — بقية أدوات لوحة المالك (بند 8-المرحلة 4-ج/د/هـ/ز/ح/ط/ي).
class OwnerMoreScreen extends StatelessWidget {
  const OwnerMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(Icons.tune_rounded, 'إعدادات المنصة', (_) => const PlatformSettingsScreen()),
      _MoreItem(Icons.account_balance_wallet_outlined, 'المالية والتسويات', (_) => const OwnerFinanceRoot()),
      _MoreItem(Icons.sos_rounded, 'متابعة SOS', (_) => const SosMonitoringScreen()),
      _MoreItem(Icons.report_gmailerrorred_outlined, 'البلاغات', (_) => const ReportsManagementScreen(isOwner: true)),
      _MoreItem(Icons.map_outlined, 'خريطة الأسطول الحيّة', (_) => const OwnerFleetMapScreen()),
      _MoreItem(Icons.phone_forwarded_outlined, 'طلب هاتفي', (_) => const PhoneOrderScreen()),
      _MoreItem(Icons.local_offer_outlined, 'أكواد الخصم', (_) => const PromoCodesScreen()),
      _MoreItem(Icons.business_center_outlined, 'مدى للأعمال', (_) => const BusinessContractsScreen()),
      _MoreItem(Icons.star_border_rounded, 'مراجعة التقييمات', (_) => const AbusiveRatingsScreen()),
      _MoreItem(Icons.search_off_rounded, 'المفقودات', (_) => const LostItemsScreen()),
      _MoreItem(Icons.backup_outlined, 'نسخة احتياطية', (_) => const BackupExportScreen()),
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
