import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/firestore_collections.dart';
import '../models/user_role.dart';

/// يراقب حالة تسجيل الدخول ويحدّد الدور من مصدرين حسب الحساسية (قرار
/// معماري موثَّق — PROJECT_STATE.md، المرحلة 1):
/// - owner/admin: حصراً من Custom Claims (لا بديل — بند 3-ب).
/// - customer/driver/officeAdmin: من مستند users/{uid}.role (self-declared،
///   محمي بـFirestore Rules من التصعيد الذاتي).
/// يُستخدم كـ refreshListenable لـ GoRouter لإعادة تقييم التوجيه فور تغيّر الحالة.
class AuthSessionNotifier extends ChangeNotifier {
  AuthSessionNotifier() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  late final StreamSubscription<User?> _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _statusDocSub;

  User? _user;
  UserRole _role = UserRole.unknown;
  bool _pendingReview = false;
  bool _isLoading = false;

  User? get user => _user;
  UserRole get role => _role;
  bool get isSignedIn => _user != null;
  bool get isPendingReview => _pendingReview;
  bool get isLoading => _isLoading;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    await _userDocSub?.cancel();
    await _statusDocSub?.cancel();

    if (user == null) {
      _role = UserRole.unknown;
      _pendingReview = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    // 1) owner/admin أولاً وحصراً من Custom Claims — لا اعتماد آخر (بند 3-ب).
    final tokenResult = await user.getIdTokenResult(true);
    final claimRole = (tokenResult.claims?['role'] as String?).toUserRole();
    if (claimRole == UserRole.owner || claimRole == UserRole.admin) {
      _role = claimRole;
      _pendingReview = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 2) customer/driver/officeAdmin — من مستند users/{uid} (يُنشأ عند اختيار الدور).
    _userDocSub = FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .snapshots()
        .listen(_onUserDocChanged);
  }

  void _onUserDocChanged(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) {
      // مستخدم جديد لم يختر دوره بعد.
      _role = UserRole.unknown;
      _pendingReview = false;
      _statusDocSub?.cancel();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _role = (data['role'] as String?).toUserRole();
    _isLoading = false;

    // حالة "قيد المراجعة" تُقرأ من مستند drivers/{uid} أو offices/{uid}
    // المرتبط (بالاتفاقية: officeId == uid للتسجيل الذاتي، بند 3-أ-4).
    _statusDocSub?.cancel();
    if (_role == UserRole.driver) {
      _statusDocSub = FirebaseFirestore.instance
          .collection(FirestoreCollections.drivers)
          .doc(_user!.uid)
          .snapshots()
          .listen((doc) {
        _pendingReview = (doc.data()?['status'] as String? ?? 'pending') == 'pending';
        notifyListeners();
      });
    } else if (_role == UserRole.officeAdmin) {
      _statusDocSub = FirebaseFirestore.instance
          .collection(FirestoreCollections.offices)
          .doc(_user!.uid)
          .snapshots()
          .listen((doc) {
        _pendingReview = (doc.data()?['approvalStatus'] as String? ?? 'pending') == 'pending';
        notifyListeners();
      });
    } else {
      _pendingReview = false;
    }

    notifyListeners();
  }

  /// يجبر تحديث Custom Claims من الخادم (مثلاً بعد منح owner/admin يدوياً).
  Future<void> refreshClaims() async {
    if (_user != null) await _onAuthChanged(_user);
  }

  @override
  void dispose() {
    _authSub.cancel();
    _userDocSub?.cancel();
    _statusDocSub?.cancel();
    super.dispose();
  }
}
