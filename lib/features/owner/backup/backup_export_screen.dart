import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// نسخة احتياطية يدوية (بند 8-المرحلة 4-ي): تصدير JSON لأهم المجموعات
/// الحرجة. ⚠️ قرار تبسيط موثَّق: بدل حفظ ملف فعلي على الجهاز (يتطلب حزمتي
/// path_provider/share_plus غير المُضمَّنتين بعد)، يُعرَض JSON كاملاً
/// بحوار قابل للنسخ (Clipboard) — يلصقه المالك بملف نصي يدوياً. يُنصَح
/// بتشغيلها أسبوعياً كما توصي المواصفة.
class BackupExportScreen extends StatefulWidget {
  const BackupExportScreen({super.key});

  @override
  State<BackupExportScreen> createState() => _BackupExportScreenState();
}

class _BackupExportScreenState extends State<BackupExportScreen> {
  bool _isExporting = false;
  String? _json;

  static const _criticalCollections = [
    FirestoreCollections.users,
    FirestoreCollections.drivers,
    FirestoreCollections.offices,
    FirestoreCollections.vehicles,
    FirestoreCollections.adminSettings,
  ];

  Future<void> _export() async {
    setState(() => _isExporting = true);
    final backup = <String, dynamic>{'exportedAt': DateTime.now().toIso8601String()};

    for (final collection in _criticalCollections) {
      final snap = await FirebaseFirestore.instance.collection(collection).limit(500).get();
      backup[collection] = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    }

    setState(() {
      _json = const JsonEncoder.withIndent('  ').convert(_sanitize(backup));
      _isExporting = false;
    });
  }

  /// يحوّل Timestamp/DocumentReference وغيرها لأنواع قابلة لـjsonEncode.
  dynamic _sanitize(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), _sanitize(v)));
    if (value is List) return value.map(_sanitize).toList();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نسخة احتياطية')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('يُصدِّر بيانات: ${_criticalCollections.join('، ')} (حتى 500 مستند لكل مجموعة).'),
            const SizedBox(height: 16),
            MadaPrimaryButton(label: 'تصدير الآن', isLoading: _isExporting, onPressed: _export),
            if (_json != null) ...[
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                  child: SingleChildScrollView(child: SelectableText(_json!, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_outlined),
                label: const Text('نسخ للحافظة'),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _json!));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
