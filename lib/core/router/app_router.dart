import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../models/user_role.dart';
import '../providers/auth_session_provider.dart';
import '../providers/pin_gate_notifier.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/legal/terms_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/role_selection/role_selection_screen.dart';
import '../../features/customer/customer_home_screen.dart';
import '../../features/driver/pending_review_screen.dart';
import '../../features/driver/driver_root_screen.dart';
import '../../features/office/office_root_screen.dart';
import '../../features/owner/owner_pin_lock_screen.dart';
import '../../features/owner/owner_root_screen.dart';
import '../../features/admin/admin_root_screen.dart';
import 'route_paths.dart';

/// التوجيه المركزي حسب الدور (Custom Claims لـowner/admin، مستند Firestore
/// ذاتي التصريح لبقية الأدوار — بند 3-د، موثَّق بالتفصيل بـPROJECT_STATE.md).
GoRouter buildAppRouter(AuthSessionNotifier authNotifier, PinGateNotifier pinGate) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: Listenable.merge([authNotifier, pinGate]),
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSignedIn = authNotifier.isSignedIn;
      final role = authNotifier.role;

      final publicPaths = {
        RoutePaths.splash,
        RoutePaths.onboarding,
        RoutePaths.terms,
        RoutePaths.login,
      };

      // مستخدم غير مسجَّل: يبقى فقط ضمن المسارات العامة.
      if (!isSignedIn) {
        return publicPaths.contains(loc) ? null : RoutePaths.splash;
      }

      // مستخدم مسجَّل لكن بلا دور بعد (أول تسجيل) → شاشة اختيار الدور (بند 3-أ-3).
      if (role == UserRole.unknown && loc != RoutePaths.roleSelection) {
        return RoutePaths.roleSelection;
      }

      // owner/admin: توجيه مباشر بلا شاشة اختيار دور إطلاقاً (بند 3-ب)،
      // لكن عبر بوابة PIN محلية إضافية أولاً (بند 8-المرحلة 4).
      if (role.isOwnerOrAdmin) {
        if (!pinGate.isVerified) {
          return loc == RoutePaths.ownerPinLock ? null : RoutePaths.ownerPinLock;
        }
        if (loc == RoutePaths.ownerHome) return null;
        return RoutePaths.ownerHome;
      }

      if (role == UserRole.customer) {
        if (loc == RoutePaths.customerHome) return null;
        return RoutePaths.customerHome;
      }

      if (role == UserRole.driver) {
        if (authNotifier.isPendingReview) {
          return loc == RoutePaths.driverPendingReview ? null : RoutePaths.driverPendingReview;
        }
        return loc == RoutePaths.driverHome ? null : RoutePaths.driverHome;
      }

      if (role == UserRole.officeAdmin) {
        if (authNotifier.isPendingReview) {
          return loc == RoutePaths.officePendingReview ? null : RoutePaths.officePendingReview;
        }
        return loc == RoutePaths.officeHome ? null : RoutePaths.officeHome;
      }

      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RoutePaths.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: RoutePaths.terms, builder: (_, __) => const TermsScreen()),
      GoRoute(path: RoutePaths.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RoutePaths.roleSelection, builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(path: RoutePaths.customerHome, builder: (_, __) => const CustomerHomeScreen()),
      GoRoute(path: RoutePaths.driverHome, builder: (_, __) => const DriverRootScreen()),
      GoRoute(
        path: RoutePaths.driverPendingReview,
        builder: (_, __) => const PendingReviewScreen(roleLabel: 'سائق', showCompleteDriverProfile: true),
      ),
      GoRoute(path: RoutePaths.officeHome, builder: (_, __) => const OfficeRootScreen()),
      GoRoute(
        path: RoutePaths.officePendingReview,
        builder: (_, __) => const PendingReviewScreen(roleLabel: 'مكتب تأجير'),
      ),
      GoRoute(
        path: RoutePaths.ownerHome,
        builder: (_, __) => authNotifier.role == UserRole.owner ? const OwnerRootScreen() : const AdminRootScreen(),
      ),
      GoRoute(path: RoutePaths.ownerPinLock, builder: (_, __) => OwnerPinLockScreen(pinGate: pinGate)),
    ],
  );
}
