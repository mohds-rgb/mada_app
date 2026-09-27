import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_collections.dart';

/// خصم العمولة تلقائياً من محفظة السائق مع كل رحلة مكتملة (بند 10 —
/// تصحيح معماري موثَّق بالمرحلة 5: كان مؤجَّلاً بالكامل لتسوية يدوية
/// بالمراحل 2-4، والمواصفة تطلبه تلقائياً). آمن رغم أن السائق نفسه من
/// يُشغِّله: القاعدة (`firestore.rules`) تُعيد حساب العمولة بنفسها من
/// `rideRequests.fare` (ثابتة بعد الإنشاء) و`adminSettings.commissionPercentage`
/// (بيد owner حصراً) — لا يقدر السائق على تمرير مبلغ مختلف عمّا تحسبه
/// القاعدة، ويُمنَع الخصم المزدوج عبر حقل `walletDeducted` على الرحلة.
class CommissionDeductionService {
  const CommissionDeductionService();

  /// idempotent: إن كانت الرحلة مخصومة مسبقاً (`walletDeducted == true`)،
  /// لا شيء يحدث — آمن الاستدعاء المتكرر (بند إعادة المحاولة عند الفشل).
  Future<void> deductForCompletedRide({required String rideId, required String driverUid}) async {
    final rideRef = FirebaseFirestore.instance.collection(FirestoreCollections.rideRequests).doc(rideId);
    final walletRef = FirebaseFirestore.instance.collection(FirestoreCollections.wallets).doc(driverUid);
    final driverRef = FirebaseFirestore.instance.collection(FirestoreCollections.drivers).doc(driverUid);
    final settingsRef =
        FirebaseFirestore.instance.collection(FirestoreCollections.adminSettings).doc(FirestoreCollections.adminSettingsDocId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final rideSnap = await tx.get(rideRef);
      final rideData = rideSnap.data();
      if (rideData == null) return;
      if (rideData['walletDeducted'] == true) return; // مخصومة مسبقاً — لا تكرار.
      if (rideData['status'] != 'completed') return;

      final walletSnap = await tx.get(walletRef);
      final driverSnap = await tx.get(driverRef);
      final settingsSnap = await tx.get(settingsRef);

      final fare = (rideData['fare'] as num?)?.toDouble() ?? 0;
      final commissionPct = (settingsSnap.data()?['commissionPercentage'] as num?)?.toDouble() ?? 15;
      final commission = fare * commissionPct / 100;

      final previousWalletBalance = (walletSnap.data()?['balance'] as num?)?.toDouble() ?? 0;
      final previousDriverBalance = (driverSnap.data()?['walletBalance'] as num?)?.toDouble() ?? 0;

      tx.set(walletRef, {
        'balance': previousWalletBalance - commission,
        'lastChargedRideId': rideId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(driverRef, {'walletBalance': previousDriverBalance - commission, 'lastChargedRideId': rideId});
      tx.update(rideRef, {'walletDeducted': true, 'commissionCharged': commission});
    });
  }
}
