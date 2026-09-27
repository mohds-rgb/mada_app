import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/providers/photo_storage_provider.dart';
import '../../shared/widgets/mada_primary_button.dart';

/// نموذج تسجيل بيانات السائق الكامل (رخصة + بيانات المركبة) — بند 3-أ-4،
/// 8-المرحلة 2. يُكمِّل مستند drivers/{uid} الذي أُنشئ فارغاً بحالة pending
/// عند اختيار الدور (المرحلة 1)؛ الحالة تبقى pending لحين اعتماد المالك.
class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _fullNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  String _vehicleType = 'اقتصادية';
  File? _licensePhoto;
  bool _isSubmitting = false;
  String? _error;

  final _vehicleTypes = const ['اقتصادية', 'Comfort', 'Premium'];

  Future<void> _pickLicensePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) setState(() => _licensePhoto = File(picked.path));
  }

  bool get _isFormValid =>
      _fullNameController.text.trim().isNotEmpty &&
      _licenseNumberController.text.trim().isNotEmpty &&
      _vehiclePlateController.text.trim().isNotEmpty &&
      _licensePhoto != null;

  Future<void> _submit() async {
    if (!_isFormValid || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final licenseUrl = await activePhotoStorageProvider.uploadImage(_licensePhoto!, folder: 'driver_licenses');
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(uid).update({
        'fullName': _fullNameController.text.trim(),
        'licenseNumber': _licenseNumberController.text.trim(),
        'licensePhotoUrl': licenseUrl,
        'vehicleType': _vehicleType,
        'vehiclePlate': _vehiclePlateController.text.trim(),
        // status يبقى 'pending' — لا يتغيّر من هنا (بند 3-ب: الاعتماد فقط من الإدارة).
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = 'تعذّر حفظ البيانات — تحقق من اتصالك وحاول مجدداً.';
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _licenseNumberController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بيانات السائق')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(controller: _fullNameController, decoration: const InputDecoration(labelText: 'الاسم الكامل'), onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            TextField(controller: _licenseNumberController, decoration: const InputDecoration(labelText: 'رقم رخصة القيادة'), onChanged: (_) => setState(() {})),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(labelText: 'فئة المركبة'),
              items: _vehicleTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _vehicleType = v!),
            ),
            const SizedBox(height: 16),
            TextField(controller: _vehiclePlateController, decoration: const InputDecoration(labelText: 'رقم اللوحة'), onChanged: (_) => setState(() {})),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickLicensePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(_licensePhoto == null ? 'تصوير رخصة القيادة' : 'تم اختيار الصورة ✓'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            MadaPrimaryButton(label: 'إرسال للمراجعة', isLoading: _isSubmitting, onPressed: _isFormValid ? _submit : null),
          ],
        ),
      ),
    );
  }
}
