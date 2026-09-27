import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/firestore_collections.dart';
import 'active_ride_screen.dart';
import 'driver_available_screen.dart';

/// جذر واجهة السائق — يبدّل تلقائياً بين لوحة الطلبات المتاحة والرحلة
/// النشطة حسب وجود طلب مُعيَّن على السائق حالياً (بند 8-المرحلة 2).
class DriverRootScreen extends StatelessWidget {
  const DriverRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestoreCollections.rideRequests)
          .where('driverId', isEqualTo: uid)
          .where('status', whereIn: ['accepted', 'arrived', 'onTrip'])
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final docs = snapshot.data!.docs;
        if (docs.isNotEmpty) return ActiveRideScreen(rideRequestId: docs.first.id);
        return const DriverAvailableScreen();
      },
    );
  }
}
