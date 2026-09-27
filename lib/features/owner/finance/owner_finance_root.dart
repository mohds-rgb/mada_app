import 'package:flutter/material.dart';
import 'platform_profit_screen.dart';
import 'settlements_screen.dart';

/// جذر المالية — تسويات السائقين + تقرير أرباح المنصة (بند 8-المرحلة 4-ج).
class OwnerFinanceRoot extends StatelessWidget {
  const OwnerFinanceRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: const TabBar(tabs: [Tab(text: 'تسويات السائقين'), Tab(text: 'أرباح المنصة')]),
          ),
          const Expanded(
            child: TabBarView(children: [SettlementsScreen(), PlatformProfitScreen()]),
          ),
        ],
      ),
    );
  }
}
