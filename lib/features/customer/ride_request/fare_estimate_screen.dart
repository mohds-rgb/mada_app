import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/models/vehicle_category.dart';
import '../../../core/providers/map_provider.dart';
import '../../../core/repositories/admin_settings_repository.dart';
import '../../../core/services/fare_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/mada_primary_button.dart';
import 'location_picker_screen.dart';
import 'ride_searching_screen.dart';

/// تقدير السعر + اختيار الفئة + تأكيد الطلب (بند 8-المرحلة 1).
class FareEstimateScreen extends StatefulWidget {
  const FareEstimateScreen({
    super.key,
    required this.pickup,
    required this.destination,
    this.onBehalfOfCustomerId,
    this.onBehalfOfCustomerName,
  });

  final LocationPickResult pickup;
  final LocationPickResult destination;
  /// عند تعبئتها: طلب هاتفي بالنيابة عن عميل من لوحة المالك (بند
  /// 8-المرحلة 4-د) — يُستخدم بدل uid المستخدم الحالي (المالك نفسه).
  final String? onBehalfOfCustomerId;
  final String? onBehalfOfCustomerName;

  @override
  State<FareEstimateScreen> createState() => _FareEstimateScreenState();
}

class _FareEstimateScreenState extends State<FareEstimateScreen> {
  RouteResult? _route;
  FareCalculator? _calculator;
  VehicleCategory _selectedCategory = VehicleCategory.economy;
  bool _isLoading = true;
  bool _isConfirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await const AdminSettingsRepository().fetch();
      if (!settings.isServiceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'الخدمة متوقفة مؤقتاً من قبل الإدارة — يرجى المحاولة لاحقاً.';
        });
        return;
      }
      final route = await activeMapProvider.getRoute(widget.pickup.point, widget.destination.point);
      if (!mounted) return;
      setState(() {
        _route = route;
        _calculator = FareCalculator(settings);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'تعذّر حساب المسار — تحقق من اتصالك بالإنترنت وحاول مجدداً.';
      });
    }
  }

  Future<void> _confirmRide() async {
    if (_route == null || _calculator == null || _isConfirming) return;
    setState(() => _isConfirming = true);

    final fare = _calculator!.estimateFare(
      distanceKm: _route!.distanceKm,
      durationMin: _route!.durationMin,
      category: _selectedCategory,
    );
    final uid = widget.onBehalfOfCustomerId ?? FirebaseAuth.instance.currentUser!.uid;
    final customerName = widget.onBehalfOfCustomerName ??
        (FirebaseAuth.instance.currentUser?.displayName?.trim().isNotEmpty == true
            ? FirebaseAuth.instance.currentUser!.displayName
            : (FirebaseAuth.instance.currentUser?.email?.split('@').first ?? 'عميل'));

    try {
      final docRef = await FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).add({
        'customerId': uid,
        'customerName': customerName,
        'isPhoneOrder': widget.onBehalfOfCustomerId != null,
        'driverId': null,
        'pickupLat': widget.pickup.point.latitude,
        'pickupLng': widget.pickup.point.longitude,
        'pickupAddress': widget.pickup.address,
        'destinationLat': widget.destination.point.latitude,
        'destinationLng': widget.destination.point.longitude,
        'destinationAddress': widget.destination.address,
        'fare': fare,
        'distanceKm': _route!.distanceKm,
        'durationMin': _route!.durationMin,
        'paymentMethod': 'cash',
        'status': 'searching',
        'walletDeducted': false, // بند 10 — يُقلَب true فور خصم العمولة تلقائياً
        'category': _selectedCategory.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => RideSearchingScreen(rideRequestId: docRef.id)));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConfirming = false;
          _error = 'تعذّر إرسال الطلب — حاول مجدداً.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الرحلة')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : Column(
                  children: [
                    SizedBox(height: 220, child: _buildRouteMap()),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAddressRow(Icons.trip_origin, widget.pickup.address),
                            const Padding(padding: EdgeInsets.only(right: 10), child: SizedBox(height: 4)),
                            _buildAddressRow(Icons.place, widget.destination.address),
                            const SizedBox(height: 8),
                            Text(
                              '${_route!.distanceKm.toStringAsFixed(1)} كم — ${_route!.durationMin.round()} دقيقة تقريباً',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            Text('اختر الفئة', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            ...VehicleCategory.values.map(_buildCategoryTile),
                            const SizedBox(height: 20),
                            Text('طريقة الدفع', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            const ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.payments_outlined),
                              title: Text('نقداً'),
                              trailing: Icon(Icons.check_circle, color: AppColors.success),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'سياسة الإلغاء: إلغاء مجاني خلال المهلة المحددة بعد قبول السائق، '
                                'وبعدها رسوم إلغاء رمزية.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 20),
                            MadaPrimaryButton(
                              label: 'تأكيد الطلب — ${_calculator!.estimateFare(distanceKm: _route!.distanceKm, durationMin: _route!.durationMin, category: _selectedCategory).toStringAsFixed(0)} ل.س',
                              isLoading: _isConfirming,
                              onPressed: _confirmRide,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAddressRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.turquoise),
        const SizedBox(width: 8),
        Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildCategoryTile(VehicleCategory category) {
    final fare = _calculator!.estimateFare(distanceKm: _route!.distanceKm, durationMin: _route!.durationMin, category: category);
    return RadioListTile<VehicleCategory>(
      contentPadding: EdgeInsets.zero,
      value: category,
      groupValue: _selectedCategory,
      onChanged: (v) => setState(() => _selectedCategory = v!),
      title: Text(category.labelAr),
      secondary: Text('${fare.toStringAsFixed(0)} ل.س', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRouteMap() {
    final points = _route!.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final pickup = LatLng(widget.pickup.point.latitude, widget.pickup.point.longitude);
    final destination = LatLng(widget.destination.point.latitude, widget.destination.point.longitude);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(coordinates: points.isEmpty ? [pickup, destination] : points, padding: const EdgeInsets.all(32)),
      ),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.mada.app'),
        if (points.isNotEmpty) PolylineLayer(polylines: [Polyline(points: points, strokeWidth: 4, color: AppColors.turquoise)]),
        MarkerLayer(markers: [
          Marker(point: pickup, child: const Icon(Icons.trip_origin, color: AppColors.success)),
          Marker(point: destination, child: const Icon(Icons.place, color: AppColors.error)),
        ]),
      ],
    );
  }
}
