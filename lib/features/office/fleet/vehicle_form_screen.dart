import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/providers/photo_storage_provider.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// إضافة/تعديل سيارة بأسطول المكتب — حتى 10 صور مضغوطة (بند 8-المرحلة 3).
class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.existingVehicleId, this.existingData});

  final String? existingVehicleId;
  final Map<String, dynamic>? existingData;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  static const _maxPhotos = 10;

  late final _plateController = TextEditingController(text: widget.existingData?['licensePlate'] as String? ?? '');
  late final _seatsController = TextEditingController(text: (widget.existingData?['seats'] as num? ?? 4).toString());
  late final _dailyController = TextEditingController(text: (widget.existingData?['priceDaily'] as num? ?? 0).toString());
  late final _weeklyController = TextEditingController(text: (widget.existingData?['priceWeekly'] as num? ?? 0).toString());
  late final _monthlyController = TextEditingController(text: (widget.existingData?['priceMonthly'] as num? ?? 0).toString());
  late String _transmission = widget.existingData?['transmission'] as String? ?? 'automatic';
  late List<String> _existingPhotoUrls = List<String>.from(widget.existingData?['photos'] as List? ?? const []);
  final List<File> _newPhotos = [];
  bool _isSaving = false;

  bool get _isEditing => widget.existingVehicleId != null;

  Future<void> _pickPhotos() async {
    final remaining = _maxPhotos - _existingPhotoUrls.length - _newPhotos.length;
    if (remaining <= 0) return;
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    setState(() => _newPhotos.addAll(picked.take(remaining).map((x) => File(x.path))));
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final uploadedUrls = <String>[];
      for (final file in _newPhotos) {
        uploadedUrls.add(await activePhotoStorageProvider.uploadImage(file, folder: 'vehicles'));
      }
      final allPhotos = [..._existingPhotoUrls, ...uploadedUrls];
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final data = {
        'officeId': uid,
        'photos': allPhotos,
        'priceDaily': double.tryParse(_dailyController.text) ?? 0,
        'priceWeekly': double.tryParse(_weeklyController.text) ?? 0,
        'priceMonthly': double.tryParse(_monthlyController.text) ?? 0,
        'transmission': _transmission,
        'seats': int.tryParse(_seatsController.text) ?? 4,
        'licensePlate': _plateController.text.trim(),
        'status': widget.existingData?['status'] as String? ?? 'available',
        'features': widget.existingData?['features'] as List? ?? [],
      };

      final col = FirebaseFirestore.instance.collection(FirestoreCollections.vehicles);
      if (_isEditing) {
        await col.doc(widget.existingVehicleId).update(data);
      } else {
        await col.add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر الحفظ — حاول مجدداً')));
      }
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _seatsController.dispose();
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPhotos = _existingPhotoUrls.length + _newPhotos.length;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'تعديل السيارة' : 'إضافة سيارة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._existingPhotoUrls.map((url) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                  )),
              ..._newPhotos.map((f) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(f, width: 80, height: 80, fit: BoxFit.cover),
                  )),
              if (totalPhotos < _maxPhotos)
                InkWell(
                  onTap: _pickPhotos,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                ),
            ],
          ),
          Text('$totalPhotos / $_maxPhotos صور', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          TextField(controller: _plateController, decoration: const InputDecoration(labelText: 'رقم اللوحة')),
          const SizedBox(height: 12),
          TextField(controller: _seatsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدد المقاعد')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _transmission,
            decoration: const InputDecoration(labelText: 'ناقل الحركة'),
            items: const [
              DropdownMenuItem(value: 'automatic', child: Text('أوتوماتيك')),
              DropdownMenuItem(value: 'manual', child: Text('يدوي')),
            ],
            onChanged: (v) => setState(() => _transmission = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _dailyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر اليومي')),
          const SizedBox(height: 12),
          TextField(controller: _weeklyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر الأسبوعي')),
          const SizedBox(height: 12),
          TextField(controller: _monthlyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر الشهري')),
          const SizedBox(height: 24),
          MadaPrimaryButton(label: 'حفظ', isLoading: _isSaving, onPressed: _save),
        ],
      ),
    );
  }
}
