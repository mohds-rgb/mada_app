import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sign_out_button.dart';
import 'bookings/office_bookings_screen.dart';
import 'fleet/vehicle_list_screen.dart';
import 'reports/office_reports_screen.dart';

/// جذر لوحة مكتب التأجير — ثلاثة تبويبات: الأسطول، الحجوزات، التقارير
/// (بند 8-المرحلة 3)، مع شريط تحذير الاشتراك عند الحاجة.
class OfficeRootScreen extends StatefulWidget {
  const OfficeRootScreen({super.key});

  @override
  State<OfficeRootScreen> createState() => _OfficeRootScreenState();
}

class _OfficeRootScreenState extends State<OfficeRootScreen> {
  int _index = 0;
  static const _titles = ['الأسطول', 'الحجوزات', 'التقارير'];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), actions: const [SignOutButton()]),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection(FirestoreCollections.offices).doc(uid).snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final subStatus = data?['subscriptionStatus'] as String?;
              if (subStatus == null || subStatus == 'active') return const SizedBox.shrink();

              final graceEnd = (data?['gracePeriodEndDate'] as Timestamp?)?.toDate();
              final daysLeft = graceEnd != null ? graceEnd.difference(DateTime.now()).inDays : null;

              return Container(
                width: double.infinity,
                color: AppColors.warning.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(12),
                child: Text(
                  subStatus == 'gracePeriod'
                      ? 'اشتراكك انتهى — أمامك ${daysLeft ?? '?'} يوم/أيام ضمن فترة السماح قبل توقف ظهورك للعملاء.'
                      : 'اشتراكك منتهٍ — يرجى تجديد الاشتراك لإعادة ظهورك للعملاء.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [VehicleListScreen(), OfficeBookingsScreen(), OfficeReportsScreen()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car), label: 'الأسطول'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'الحجوزات'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'التقارير'),
        ],
      ),
    );
  }
}
