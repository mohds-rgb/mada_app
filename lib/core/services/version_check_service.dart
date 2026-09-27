/// مقارنة إصدارات دلالية بسيطة (major.minor.patch) — بند 16 (Force Update).
class VersionCheckService {
  const VersionCheckService();

  /// true إن كان [current] أقدم من [minimum] (يستوجب تحديثاً إلزامياً).
  bool isBelowMinimum(String current, String minimum) {
    final c = _parse(current);
    final m = _parse(minimum);
    for (var i = 0; i < 3; i++) {
      if (c[i] != m[i]) return c[i] < m[i];
    }
    return false;
  }

  List<int> _parse(String version) {
    final parts = version.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }
}
