import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_more_screen.dart';
import '../moderation/reports_management_screen.dart';
import '../../shared/widgets/sign_out_button.dart';

/// جذر لوحة الأدمن التشغيلي العامة (بند 8-المرحلة 4.5) — نفس صلاحيات
/// الإشراف دون الصلاحيات المالية وإدارة الاشتراكات. لا صلاحية حظر نهائي
/// أو تعديل نسب مالية — تلك حصراً لـowner (مفروضة أيضاً بـFirestore Rules).
class AdminRootScreen extends StatefulWidget {
  const AdminRootScreen({super.key});

  @override
  State<AdminRootScreen> createState() => _AdminRootScreenState();
}

class _AdminRootScreenState extends State<AdminRootScreen> {
  int _index = 0;
  static const _titles = ['لوحة القيادة', 'البلاغات', 'المزيد'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), actions: const [SignOutButton()]),
      body: IndexedStack(
        index: _index,
        children: const [
          AdminDashboardScreen(),
          ReportsManagementScreen(isOwner: false),
          AdminMoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'لوحة القيادة'),
          NavigationDestination(icon: Icon(Icons.report_gmailerrorred_outlined), selectedIcon: Icon(Icons.report), label: 'البلاغات'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.more_horiz_rounded), label: 'المزيد'),
        ],
      ),
    );
  }
}
