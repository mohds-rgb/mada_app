/// بيئتا التشغيل (Flavors) — تطوير/إنتاج (بند 5: "بيئتا Firebase منفصلتان").
enum AppFlavor { dev, prod }

class AppConfig {
  AppConfig._internal(this.flavor);

  static AppConfig? _instance;
  final AppFlavor flavor;

  static void init(AppFlavor flavor) {
    _instance = AppConfig._internal(flavor);
  }

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig.init() لم يُستدعَ بعد — استدعِه من main_dev.dart أو main_prod.dart');
    return _instance!;
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  String get appTitle => isDev ? 'مدى (تطوير)' : 'مدى';

  // -------- Cloudinary (CloudinaryStorageProvider — بند 5) --------
  // القيم الفعلية المؤكدة من حساب Cloudinary المجاني (بلا بطاقة بنكية).
  static const String cloudinaryCloudName = 'wbkfbdsp';
  static const String cloudinaryUploadPreset = 'mada_preset';
  static String get cloudinaryUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';
}
