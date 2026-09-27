import 'package:device_info_plus/device_info_plus.dart';

/// بصمة جهاز تقريبية — تُخزَّن بمستند المستخدم عند إنشاء الحساب لأول مرة
/// (بند 12-هـ، 13-د) لتمكين ربط الحظر النهائي بالجهاز ومنع الالتفاف عليه
/// بحساب جديد على نفس الجهاز (bannedDevices — بند 8-المرحلة 4.5).
/// ⚠️ تقريبية عمداً: معرّف منصة (Android ID / identifierForVendor iOS)
/// قابل للتغيّر بإعادة ضبط المصنع أو حذف التطبيق على iOS — وسيلة ردع لا
/// حماية مطلَقة، وموثَّق كذلك.
class DeviceFingerprintService {
  const DeviceFingerprintService();

  Future<String?> currentFingerprint() async {
    try {
      final plugin = DeviceInfoPlugin();
      final androidInfo = await plugin.androidInfo;
      return androidInfo.id; // Android ID — قابل للتغيّر لكنه أفضل مؤشر متاح بلا أذونات إضافية
    } catch (_) {
      return null; // منصة غير مدعومة أو فشل القراءة — لا يوقف تدفق التسجيل أبداً
    }
  }
}
