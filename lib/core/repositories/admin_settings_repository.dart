import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_collections.dart';
import '../models/admin_settings_model.dart';

/// يجلب adminSettings/global من Firestore. إن لم يوجد المستند بعد (لم
/// يستورده المالك عبر seed_data بعد) — يعود بأمان للقيم الافتراضية
/// المضمَّنة في AdminSettingsModel نفسها، فلا يُعطَّل التطبيق أبداً.
class AdminSettingsRepository {
  const AdminSettingsRepository();

  Future<AdminSettingsModel> fetch() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.adminSettings)
          .doc(FirestoreCollections.adminSettingsDocId)
          .get();
      if (!doc.exists || doc.data() == null) return const AdminSettingsModel();
      return AdminSettingsModel.fromMap(doc.data()!);
    } catch (_) {
      return const AdminSettingsModel();
    }
  }
}
