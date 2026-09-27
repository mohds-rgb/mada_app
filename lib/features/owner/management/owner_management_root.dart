import 'package:flutter/material.dart';
import 'customers_management_screen.dart';
import 'drivers_management_screen.dart';
import 'offices_management_screen.dart';

/// جذر الإدارة — سائقون / مكاتب / عملاء (بند 8-المرحلة 4-ب).
class OwnerManagementRoot extends StatelessWidget {
  const OwnerManagementRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: const TabBar(tabs: [Tab(text: 'السائقون'), Tab(text: 'المكاتب'), Tab(text: 'العملاء')]),
          ),
          const Expanded(
            child: TabBarView(
              children: [DriversManagementScreen(), OfficesManagementScreen(), CustomersManagementScreen()],
            ),
          ),
        ],
      ),
    );
  }
}
