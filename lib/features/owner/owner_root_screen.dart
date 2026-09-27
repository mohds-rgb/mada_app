import 'package:flutter/material.dart';
import 'dashboard/owner_dashboard_screen.dart';
import 'management/owner_management_root.dart';
import 'owner_more_screen.dart';
import '../../shared/widgets/sign_out_button.dart';

/// جذر لوحة المالك/الأدمن — لوحة القيادة، الإدارة، والمزيد (بند 8-المرحلة 4).
class OwnerRootScreen extends StatefulWidget {
  const OwnerRootScreen({super.key});

  @override
  State<OwnerRootScreen> createState() => _OwnerRootScreenState();
}

class _OwnerRootScreenState extends State<OwnerRootScreen> {
  int _index = 0;
  static const _titles = ['لوحة القيادة', 'الإدارة', 'المزيد'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), actions: const [SignOutButton()]),
      body: IndexedStack(
        index: _index,
        children: const [OwnerDashboardScreen(), OwnerManagementRoot(), OwnerMoreScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'لوحة القيادة'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'الإدارة'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.more_horiz_rounded), label: 'المزيد'),
        ],
      ),
    );
  }
}
