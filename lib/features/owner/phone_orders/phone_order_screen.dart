import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/firestore_collections.dart';
import '../../customer/ride_request/fare_estimate_screen.dart';
import '../../customer/ride_request/location_picker_screen.dart';
import '../../../shared/widgets/mada_primary_button.dart';

/// طلب رحلة هاتفي بالنيابة عن عميل — مركز الاتصال (بند 8-المرحلة 4-د).
/// يبحث عن العميل بالبريد الإلكتروني (الحقل الوحيد المؤكَّد الجمع حالياً)
/// ثم يعيد استخدام نفس تدفق اختيار المواقع وتقدير السعر من تطبيق العميل.
class PhoneOrderScreen extends StatefulWidget {
  const PhoneOrderScreen({super.key});

  @override
  State<PhoneOrderScreen> createState() => _PhoneOrderScreenState();
}

class _PhoneOrderScreenState extends State<PhoneOrderScreen> {
  final _emailController = TextEditingController();
  bool _isSearching = false;
  String? _error;
  String? _foundCustomerId;
  String? _foundCustomerName;

  Future<void> _search() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _isSearching) return;
    setState(() {
      _isSearching = true;
      _error = null;
      _foundCustomerId = null;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'customer')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _error = 'لا يوجد عميل مسجَّل بهذا البريد. يجب أن يُنشئ حساباً عبر التطبيق أولاً.');
      } else {
        final doc = query.docs.first;
        setState(() {
          _foundCustomerId = doc.id;
          _foundCustomerName = doc.data()['displayName'] as String? ?? email.split('@').first;
        });
      }
    } catch (e) {
      setState(() => _error = 'تعذّر البحث — حاول مجدداً.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _startOrder() async {
    if (_foundCustomerId == null) return;

    final pickup = await Navigator.push<LocationPickResult>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen(title: 'نقطة الانطلاق')),
    );
    if (pickup == null || !mounted) return;

    final destination = await Navigator.push<LocationPickResult>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(title: 'الوجهة', initialPoint: pickup.point)),
    );
    if (destination == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FareEstimateScreen(
          pickup: pickup,
          destination: destination,
          onBehalfOfCustomerId: _foundCustomerId,
          onBehalfOfCustomerName: _foundCustomerName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب هاتفي')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('ابحث عن العميل ببريده الإلكتروني المسجَّل بالتطبيق:'),
            const SizedBox(height: 12),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'email@example.com')),
            const SizedBox(height: 12),
            MadaPrimaryButton(label: 'بحث', isLoading: _isSearching, onPressed: _search),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ],
            if (_foundCustomerId != null) ...[
              const SizedBox(height: 20),
              Card(child: ListTile(leading: const Icon(Icons.person), title: Text(_foundCustomerName ?? ''))),
              const SizedBox(height: 12),
              MadaPrimaryButton(label: 'متابعة — اختيار المواقع', onPressed: _startOrder),
            ],
          ],
        ),
      ),
    );
  }
}
