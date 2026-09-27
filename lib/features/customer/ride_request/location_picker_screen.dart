import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/providers/map_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/mada_primary_button.dart';

class LocationPickResult {
  const LocationPickResult(this.point, this.address);
  final GeoPoint2D point;
  final String address;
}

/// اختيار موقع (استلام أو وجهة) على الخريطة — دبّوس مركزي ثابت + بحث نصي
/// (بند 8-المرحلة 1: "استلام/وجهة على الخريطة").
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, required this.title, this.initialPoint});

  final String title;
  final GeoPoint2D? initialPoint;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _daraaCenter = LatLng(32.6189, 36.1021);

  final _mapController = MapController();
  final _searchController = TextEditingController();
  LatLng _center = _daraaCenter;
  String _address = '';
  bool _isResolvingAddress = false;
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialPoint != null) {
      _center = LatLng(widget.initialPoint!.latitude, widget.initialPoint!.longitude);
      _resolveAddress(_center);
    } else {
      _useCurrentLocation();
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = point);
      _mapController.move(point, 15);
      _resolveAddress(point);
    } catch (_) {
      _resolveAddress(_center); // fallback: مركز درعا الافتراضي
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
      _center = _mapController.camera.center;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () => _resolveAddress(_center));
    }
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _isResolvingAddress = true);
    try {
      final address = await activeMapProvider.reverseGeocode(GeoPoint2D(point.latitude, point.longitude));
      if (mounted) setState(() => _address = address);
    } catch (_) {
      if (mounted) setState(() => _address = '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}');
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching) return;
    setState(() => _isSearching = true);
    try {
      final results = await activeMapProvider.geocode(query);
      if (results.isNotEmpty) {
        final point = LatLng(results.first.latitude, results.first.longitude);
        _mapController.move(point, 15);
        setState(() => _center = point);
        await _resolveAddress(point);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم يتم العثور على نتائج')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر البحث — تحقق من الاتصال')));
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mada.app',
              ),
            ],
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(Icons.location_pin, size: 44, color: AppColors.error),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مكان...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  filled: true,
                  suffixIcon: _isSearching
                      ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(icon: const Icon(Icons.search), onPressed: _search),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isResolvingAddress ? 'جارٍ تحديد العنوان...' : _address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MadaPrimaryButton(
                      label: 'تأكيد هذا الموقع',
                      isLoading: _isResolvingAddress,
                      onPressed: _isResolvingAddress
                          ? null
                          : () => Navigator.pop(
                                context,
                                LocationPickResult(GeoPoint2D(_center.latitude, _center.longitude), _address),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
