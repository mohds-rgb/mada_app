import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/repositories/admin_settings_repository.dart';
import '../../core/services/location_update_policy.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sign_out_button.dart';

/// شاشة السائق المتصل: تبديل online/offline + قائمة الطلبات القريبة
/// (بند 8-المرحلة 2). يكتب الموقع بتردد LocationUpdatePolicy (20ث افتراضياً
/// من المرحلة 0.5).
///
/// ⚠️ قيد مؤقت موثَّق: لا مطابقة جغرافية خادمية (geohash query) بعد — يُجلب
/// كل الطلبات "searching" غير المُعيَّنة ثم تُرتَّب محلياً حسب المسافة
/// الفعلية من موقع السائق (Geolocator.distanceBetween). كافٍ لحجم MVP؛
/// الانتقال لـgeoflutterfire2 (موجودة بالمشروع مسبقاً) مخطَّط له عند نمو
/// عدد السائقين المتزامنين.
class DriverAvailableScreen extends StatefulWidget {
  const DriverAvailableScreen({super.key});

  @override
  State<DriverAvailableScreen> createState() => _DriverAvailableScreenState();
}

class _DriverAvailableScreenState extends State<DriverAvailableScreen> {
  bool _isOnline = false;
  Position? _lastPosition;
  Timer? _locationTimer;
  int _intervalSeconds = 20;
  double _maxUnsettledDebt = 100000;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    const AdminSettingsRepository().fetch().then((s) {
      if (mounted) _maxUnsettledDebt = s.maxUnsettledDebt;
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _toggleOnline(bool value) async {
    setState(() => _isOnline = value);
    if (value) {
      final settings = await const AdminSettingsRepository().fetch();
      _intervalSeconds = LocationUpdatePolicy(settings).currentIntervalSeconds;
      await _pushLocation();
      _locationTimer = Timer.periodic(Duration(seconds: _intervalSeconds), (_) => _pushLocation());
    } else {
      _locationTimer?.cancel();
    }
  }

  Future<void> _pushLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      _lastPosition = pos;
      await FirebaseFirestore.instance.collection(FirestoreCollections.vehicleLocations).doc(_uid).set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'driverApp',
      });
    } catch (_) {
      // فشل عرضي بالموقع لا يوقف التطبيق — سيُعاد المحاولة بالدورة التالية.
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    final rideRef = FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).doc(requestId);
    final userRef = FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(_uid);
    final driverRef = FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(_uid);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final rideSnap = await tx.get(rideRef);
        if (rideSnap.data()?['driverId'] != null) {
          throw Exception('تم قبول هذا الطلب من سائق آخر للتو');
        }
        // بيانات مُبَعثَرة (denormalized) على مستند الطلب نفسه لإتاحة عرضها
        // للعميل دون الحاجة لتوسيع صلاحيات قراءة users/{driverId} العامة
        // (بند 12 — قراءة users محصورة بصاحب الحساب فقط).
        final userSnap = await tx.get(userRef);
        final driverSnap = await tx.get(driverRef);
        final driverData = driverSnap.data() ?? {};
        final userData = userSnap.data() ?? {};

        tx.update(rideRef, {
          'driverId': _uid,
          'status': 'accepted',
          'driverName': driverData['fullName'] as String? ?? '',
          'driverPhone': userData['phone'] as String?,
          'vehiclePlate': driverData['vehiclePlate'] as String? ?? '',
          'driverRating': driverData['rating'] as num? ?? 5.0,
        });
      });
      // DriverRootScreen يستمع لنفس الاستعلام وسيبدّل تلقائياً لشاشة
      // الرحلة النشطة فور نجاح القبول — لا تنقّل يدوي هنا.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة السائق'),
        actions: const [SignOutButton()],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(_uid).snapshots(),
        builder: (context, driverSnap) {
          final walletBalance = (driverSnap.data?.data()?['walletBalance'] as num?)?.toDouble() ?? 0;
          // سياسة عدم السداد (بند 10): تعليق استقبال طلبات جديدة تلقائياً
          // عند تجاوز الدَين الحد الأقصى المسموح — لا يمنع الوصول للتطبيق،
          // فقط يعطّل "الاتصال" لاستقبال طلبات جديدة.
          final isSuspended = walletBalance <= -_maxUnsettledDebt;

          if (isSuspended && _isOnline) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _toggleOnline(false));
          }

          return Column(
            children: [
              if (isSuspended)
                Container(
                  width: double.infinity,
                  color: AppColors.error.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'حسابك موقوف مؤقتاً عن استقبال طلبات جديدة بسبب دَين مستحق '
                    '(${walletBalance.abs().toStringAsFixed(0)} ل.س). يرجى التواصل مع الإدارة لتسوية الحساب.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              SwitchListTile(
                value: _isOnline,
                onChanged: isSuspended ? null : _toggleOnline,
                title: Text(_isOnline ? 'متصل — متاح لاستقبال الطلبات' : 'غير متصل'),
                secondary: Icon(_isOnline ? Icons.wifi : Icons.wifi_off, color: _isOnline ? AppColors.success : null),
              ),
              const Divider(height: 1),
              Expanded(
                child: !_isOnline
                    ? Center(child: Text(isSuspended ? 'إيقاف مؤقت — راجع الإدارة' : 'فعّل الاتصال لعرض الطلبات القريبة'))
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection(FirestoreCollections.rideRequests)
                            .where('status', isEqualTo: 'searching')
                            .where('driverId', isEqualTo: null)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) return const Center(child: Text('لا توجد طلبات قريبة حالياً'));

                          final items = docs.map((d) {
                            final data = d.data();
                            double? distanceKm;
                            if (_lastPosition != null) {
                              distanceKm = Geolocator.distanceBetween(
                                    _lastPosition!.latitude,
                                    _lastPosition!.longitude,
                                    (data['pickupLat'] as num).toDouble(),
                                    (data['pickupLng'] as num).toDouble(),
                                  ) /
                                  1000;
                            }
                            return (id: d.id, data: data, distanceKm: distanceKm);
                          }).toList()
                            ..sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));

                          return ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final item = items[i];
                              final fare = (item.data['fare'] as num?)?.toDouble() ?? 0;
                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  title: Text(item.data['pickupAddress'] as String? ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text(
                                    '${item.data['destinationAddress'] ?? ''}\n'
                                    '${fare.toStringAsFixed(0)} ل.س'
                                    '${item.distanceKm != null ? ' — ${item.distanceKm!.toStringAsFixed(1)} كم' : ''}',
                                  ),
                                  isThreeLine: true,
                                  trailing: ElevatedButton(onPressed: () => _acceptRequest(item.id), child: const Text('قبول')),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
