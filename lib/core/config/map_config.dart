/// إعدادات مزوّد الخرائط النشط (بند 5، 8-المرحلة 0.5، 17-ج).
class MapConfig {
  MapConfig._();

  /// مفتاح OpenRouteService المجاني (Standard — 2,000 طلب/يوم) — بند 17-ج.
  static const String openRouteServiceApiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjNkMGU3MzU2OWY4ZDRkMDViYmY0ZTg2MmY3OGIyMDc1IiwiaCI6Im11cm11cjY0In0=';

  static const String openRouteServiceDirectionsUrl =
      'https://api.openrouteservice.org/v2/directions/driving-car';

  static const String nominatimSearchUrl = 'https://nominatim.openstreetmap.org/search';
  static const String nominatimReverseUrl = 'https://nominatim.openstreetmap.org/reverse';

  // User-Agent مخصَّص إلزامي وفق سياسة استخدام Nominatim العادلة.
  static const String nominatimUserAgent = 'MadaApp/1.0 (contact: support@mada.app)';

  // صندوق حدود تقريبي لمحافظة درعا — يُستخدم لتحسين نتائج البحث محلياً
  // (bounded=0 اختيارياً — تحيّز فقط، لا حصر صارم، بند 6).
  static const double daraaMinLat = 32.45;
  static const double daraaMaxLat = 32.75;
  static const double daraaMinLng = 35.95;
  static const double daraaMaxLng = 36.35;
}
