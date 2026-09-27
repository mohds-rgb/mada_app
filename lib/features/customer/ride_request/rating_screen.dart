import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// تقييم السائق بعد إكمال الرحلة (بند 7 — ratings، 8-المرحلة 1).
class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.rideRequestId, required this.driverId, required this.driverName});

  final String rideRequestId;
  final String driverId;
  final String driverName;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 5;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.ratings).add({
        'fromUserId': FirebaseAuth.instance.currentUser!.uid,
        'toUserId': widget.driverId,
        'tripId': widget.rideRequestId,
        'stars': _stars,
        'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        'tags': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قيّم رحلتك'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('كيف كانت رحلتك مع ${widget.driverName}؟', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                return IconButton(
                  iconSize: 36,
                  onPressed: () => setState(() => _stars = starIndex),
                  icon: Icon(
                    starIndex <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.gold,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'ملاحظة (اختياري)'),
            ),
            const SizedBox(height: 20),
            MadaPrimaryButton(label: 'إرسال التقييم', isLoading: _isSubmitting, onPressed: _submit),
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('تخطي'),
            ),
          ],
        ),
      ),
    );
  }
}
