import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../config/map_config.dart';

class GeoPoint2D {
  const GeoPoint2D(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class RouteResult {
  const RouteResult({required this.points, required this.distanceKm, required this.durationMin});
  final List<GeoPoint2D> points;
  final double distanceKm;
  final double durationMin;
}

/// واجهة الخرائط القابلة للتبديل (بند 5).
abstract class MapProvider {
  Future<List<GeoPoint2D>> geocode(String address);
  Future<String> reverseGeocode(GeoPoint2D point);
  Future<RouteResult> getRoute(GeoPoint2D from, GeoPoint2D to);
  bool get requiresPaymentCard;
}

/// ============ النشط الآن — بصفر تكلفة (بند 5، 8-0.5، 17-ج) ============
/// flutter_map + بلاطات OSM، Geocoding عبر Nominatim، مسارات فعلية عبر
/// OpenRouteService (مفتاح مجاني مُؤكَّد — 2,000 طلب/يوم).
class OsmMapProvider implements MapProvider {
  const OsmMapProvider();

  @override
  bool get requiresPaymentCard => false;

  @override
  Future<List<GeoPoint2D>> geocode(String address) async {
    final uri = Uri.parse(MapConfig.nominatimSearchUrl).replace(queryParameters: {
      'q': address,
      'format': 'json',
      'limit': '5',
      'countrycodes': 'sy',
      'viewbox':
          '${MapConfig.daraaMinLng},${MapConfig.daraaMaxLat},${MapConfig.daraaMaxLng},${MapConfig.daraaMinLat}',
    });

    final response = await http.get(uri, headers: {'User-Agent': MapConfig.nominatimUserAgent});
    if (response.statusCode != 200) {
      throw Exception('فشل البحث الجغرافي (Nominatim): ${response.statusCode}');
    }

    final List<dynamic> results = jsonDecode(response.body) as List<dynamic>;
    return results
        .map((r) => GeoPoint2D(double.parse(r['lat'] as String), double.parse(r['lon'] as String)))
        .toList();
  }

  @override
  Future<String> reverseGeocode(GeoPoint2D point) async {
    final uri = Uri.parse(MapConfig.nominatimReverseUrl).replace(queryParameters: {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'format': 'json',
    });

    final response = await http.get(uri, headers: {'User-Agent': MapConfig.nominatimUserAgent});
    if (response.statusCode != 200) {
      throw Exception('فشل تحديد العنوان من الموقع (Nominatim): ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['display_name'] as String? ?? '${point.latitude}, ${point.longitude}';
  }

  @override
  Future<RouteResult> getRoute(GeoPoint2D from, GeoPoint2D to) async {
    final uri = Uri.parse(MapConfig.openRouteServiceDirectionsUrl);
    final response = await http.post(
      uri,
      headers: {
        'Authorization': MapConfig.openRouteServiceApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coordinates': [
          [from.longitude, from.latitude],
          [to.longitude, to.latitude],
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل حساب المسار (OpenRouteService): ${response.statusCode} — ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw Exception('لا يوجد مسار متاح بين النقطتين');
    }
    final route = routes.first as Map<String, dynamic>;
    final summary = route['summary'] as Map<String, dynamic>;
    final encodedPolyline = route['geometry'] as String;

    final decoded = PolylinePoints().decodePolyline(encodedPolyline);
    final points = decoded.map((p) => GeoPoint2D(p.latitude, p.longitude)).toList();

    return RouteResult(
      points: points,
      distanceKm: (summary['distance'] as num) / 1000,
      durationMin: (summary['duration'] as num) / 60,
    );
  }
}

/// ============ Stub جاهز، معطَّل ============
class GoogleMapProvider implements MapProvider {
  const GoogleMapProvider();

  @override
  bool get requiresPaymentCard => true;

  @override
  Future<List<GeoPoint2D>> geocode(String address) =>
      throw UnsupportedError('GoogleMapProvider معطَّل حالياً — يتطلب مفتاح ومزانية (بند 5، 15)');

  @override
  Future<String> reverseGeocode(GeoPoint2D point) =>
      throw UnsupportedError('GoogleMapProvider معطَّل حالياً');

  @override
  Future<RouteResult> getRoute(GeoPoint2D from, GeoPoint2D to) =>
      throw UnsupportedError('GoogleMapProvider معطَّل حالياً');
}

/// نقطة تبديل المزوّد النشط — سطر واحد فقط.
const MapProvider activeMapProvider = OsmMapProvider();
