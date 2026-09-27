import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/firestore_collections.dart';

/// نص الموافقة الرسمي — حرفياً كما ورد بالمواصفة (بند 11)، لا يُعدَّل
/// ولا يُطمَر بشروط عامة أخرى.
const String rentalTrackingConsentText =
    'بضغطك على متابعة، أنت توافق على مشاركة موقع الهاتف بشكل لحظي مع مكتب '
    'التأجير طوال مدة الحجز النشطة فقط، لأغراض السلامة ومتابعة السيارة. '
    'تتوقف المشاركة تلقائياً عند إنهاء الحجز، ويمكنك إيقافها يدوياً عبر زر '
    "'انقطع التتبع' (يظهر عندها للمكتب كحالة 'غير متصل').";

/// تتبع موقع المستأجر أثناء حجز نشط (بند 11) — يكتب لنفس مجموعة
/// vehicleLocations التي يقرؤها المكتب/المالك (بند 8-المرحلة 3/4)، بمعرّف
/// السيارة المحجوزة نفسها.
class RentalTrackingService {
  RentalTrackingService(this._vehicleId);

  final String _vehicleId;
  Timer? _timer;

  bool get isTracking => _timer != null;

  Future<void> start({int intervalSeconds = 20}) async {
    await _push();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => _push());
  }

  /// "انقطع التتبع" — إيقاف يدوي فوري، يظهر للمكتب كحالة غير متصل (بند 11).
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await FirebaseFirestore.instance.collection(FirestoreCollections.vehicleLocations).doc(_vehicleId).set(
      {'trackingActive': false, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> _push() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      await FirebaseFirestore.instance.collection(FirestoreCollections.vehicleLocations).doc(_vehicleId).set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'renterApp',
        'trackingActive': true,
      });
    } catch (_) {
      // فشل عرضي — يُعاد المحاولة بالدورة التالية.
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
