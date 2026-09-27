import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/repositories/admin_settings_repository.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// حجز سيارة: اختيار تاريخي استلام/إرجاع + حساب السعر والعربون (بند
/// 8-المرحلة 1، 3، 14).
/// ⚠️ قرار تبسيط موثَّق: يُحسَب السعر حالياً بالسعر اليومي × عدد الأيام
/// دوماً (بلا تحسين تلقائي للسعر الأسبوعي/الشهري الأرخص) — تحسين لاحق ممكن
/// دون تغيير بنية البيانات.
class VehicleBookingScreen extends StatefulWidget {
  const VehicleBookingScreen({super.key, required this.vehicleId, required this.vehicleData});

  final String vehicleId;
  final Map<String, dynamic> vehicleData;

  @override
  State<VehicleBookingScreen> createState() => _VehicleBookingScreenState();
}

class _VehicleBookingScreenState extends State<VehicleBookingScreen> {
  DateTimeRange? _range;
  double _depositPercentage = 20;
  bool _isBooking = false;
  bool _serviceEnabled = true;

  @override
  void initState() {
    super.initState();
    const AdminSettingsRepository().fetch().then((s) {
      if (mounted) setState(() {
        _depositPercentage = s.depositPercentage;
        _serviceEnabled = s.isServiceEnabled;
      });
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(start: now.add(const Duration(days: 1)), end: now.add(const Duration(days: 3))),
    );
    if (picked != null) setState(() => _range = picked);
  }

  int get _days => _range == null ? 0 : _range!.end.difference(_range!.start).inDays + 1;

  double get _total => _days * ((widget.vehicleData['priceDaily'] as num?)?.toDouble() ?? 0);

  double get _deposit => _total * _depositPercentage / 100;

  Future<void> _confirm() async {
    if (_range == null || _isBooking) return;
    if (!_serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الخدمة متوقفة مؤقتاً من قبل الإدارة — يرجى المحاولة لاحقاً.')));
      return;
    }
    setState(() => _isBooking = true);
    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.rentalBookings).add({
        'customerId': FirebaseAuth.instance.currentUser!.uid,
        'officeId': widget.vehicleData['officeId'],
        'vehicleId': widget.vehicleId,
        'startDate': Timestamp.fromDate(_range!.start),
        'endDate': Timestamp.fromDate(_range!.end),
        'total': _total,
        'depositAmount': _deposit,
        'depositStatus': 'pending',
        'status': 'pending',
        'pickupPhotos': <String>[],
        'returnPhotos': <String>[],
        'extensionRequests': <Map<String, dynamic>>[],
        'lateFee': 0,
      });
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب الحجز — بانتظار موافقة المكتب')));
      }
    } catch (e) {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(widget.vehicleData['priceDaily'] as num?) ?? 0} ل.س / يوم', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range_outlined),
              label: Text(_range == null ? 'اختر تاريخ الاستلام والإرجاع' : '$_days يوم/أيام محدَّدة'),
            ),
            const SizedBox(height: 20),
            if (_range != null) ...[
              _row('الإجمالي', '${_total.toStringAsFixed(0)} ل.س'),
              _row('العربون ($_depositPercentage%)', '${_deposit.toStringAsFixed(0)} ل.س'),
            ],
            const Spacer(),
            MadaPrimaryButton(label: 'تأكيد الحجز', isLoading: _isBooking, onPressed: _range != null ? _confirm : null),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
      );
}
