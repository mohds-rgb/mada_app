import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../config/app_config.dart';

/// واجهة تخزين الصور القابلة للتبديل (بند 5).
abstract class PhotoStorageProvider {
  /// يرفع صورة (بعد ضغطها إلزامياً — بند 5) ويُعيد رابط URL فعلياً يُخزَّن
  /// كحقل نصي داخل مستند Firestore المناسب.
  Future<String> uploadImage(File imageFile, {required String folder});

  bool get requiresPaymentCard;
}

/// ============ النشط الآن — بلا بطاقة بنكية (بند 5) ============
/// رفع مباشر (Unsigned Upload Preset) لصور الرخص والسيارات والملفات الشخصية.
class CloudinaryStorageProvider implements PhotoStorageProvider {
  const CloudinaryStorageProvider();

  @override
  bool get requiresPaymentCard => false;

  @override
  Future<String> uploadImage(File imageFile, {required String folder}) async {
    // ضغط الصورة إلزامي قبل أي رفع (بند 5).
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      quality: 75,
      minWidth: 1280,
      minHeight: 1280,
    );
    final bytes = compressed ?? await imageFile.readAsBytes();

    final uri = Uri.parse(AppConfig.cloudinaryUploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..fields['folder'] = 'mada/$folder'
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('فشل رفع الصورة إلى Cloudinary: ${response.statusCode} — ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String?;
    if (secureUrl == null) {
      throw Exception('استجابة Cloudinary لا تحتوي secure_url');
    }
    return secureUrl;
  }
}

/// ============ Stub جاهز، معطَّل — يتطلب Blaze ============
class FirebaseStorageProvider implements PhotoStorageProvider {
  const FirebaseStorageProvider();

  @override
  bool get requiresPaymentCard => true;

  @override
  Future<String> uploadImage(File imageFile, {required String folder}) =>
      throw UnsupportedError('FirebaseStorageProvider معطَّل حالياً — يتطلب باقة Blaze (بند 5، 15، 17)');
}

/// نقطة تبديل المزوّد النشط — سطر واحد فقط.
const PhotoStorageProvider activePhotoStorageProvider = CloudinaryStorageProvider();
