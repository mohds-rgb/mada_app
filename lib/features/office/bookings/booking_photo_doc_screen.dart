import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/providers/photo_storage_provider.dart';
import '../../../core/repositories/admin_settings_repository.dart';
import '../../../core/services/rental_policy_calculator.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// توثيق حالة السيارة بالصور عند الاستلام أو الإرجاع — إلزامي (بند
/// 8-المرحلة 3، 13). عند الإرجاع، يُحسَب فعلياً أي غرامة تأخير ويُحدَّث
/// `lateFee` على مستند الحجز.
class BookingPhotoDocScreen extends StatefulWidget {
  const BookingPhotoDocScreen({
    super.key,
    required this.bookingId,
    required this.isPickup,
    this.scheduledEndDate,
  });

  final String bookingId;
  final bool isPickup;
  final DateTime? scheduledEndDate;

  @override
  State<BookingPhotoDocScreen> createState() => _BookingPhotoDocScreenState();
}

class _BookingPhotoDocScreenState extends State<BookingPhotoDocScreen> {
  static const _minPhotos = 3;
  final List<File> _photos = [];
  bool _isSaving = false;

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    setState(() => _photos.addAll(picked.map((x) => File(x.path))));
  }

  Future<void> _submit() async {
    if (_photos.length < _minPhotos || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final urls = <String>[];
      for (final file in _photos) {
        urls.add(await activePhotoStorageProvider.uploadImage(file, folder: widget.isPickup ? 'rental_pickup' : 'rental_return'));
      }

      final ref = FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).doc(widget.bookingId);

      if (widget.isPickup) {
        await ref.update({'pickupPhotos': urls, 'status': 'active'});
      } else {
        double lateFee = 0;
        if (widget.scheduledEndDate != null) {
          final settings = await const AdminSettingsRepository().fetch();
          lateFee = const RentalPolicyCalculator().lateFee(
            actualReturnTime: DateTime.now(),
            scheduledEndDate: widget.scheduledEndDate!,
            lateFeePerHour: settings.lateFeePerHour,
          );
        }
        await ref.update({'returnPhotos': urls, 'status': 'completed', 'lateFee': lateFee});
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isPickup ? 'توثيق الاستلام' : 'توثيق الإرجاع')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقط $_minPhotos صور على الأقل توثّق حالة السيارة الحالية (كل الجهات + أي ضرر ملحوظ).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._photos.map((f) => ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(f, width: 80, height: 80, fit: BoxFit.cover))),
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
            const SizedBox(height: 8),
            Text('${_photos.length} / $_minPhotos (حد أدنى)', style: Theme.of(context).textTheme.bodySmall),
            const Spacer(),
            MadaPrimaryButton(
              label: widget.isPickup ? 'تأكيد الاستلام' : 'تأكيد الإرجاع',
              isLoading: _isSaving,
              onPressed: _photos.length >= _minPhotos ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
