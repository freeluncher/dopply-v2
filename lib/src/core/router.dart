import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/create_patient_profile_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/monitoring/presentation/monitoring_screen.dart';
import '../features/records/presentation/records_screen.dart';
import '../features/records/presentation/record_detail_screen.dart';
import '../features/dashboard/presentation/doctor_patients_screen.dart';
import '../features/dashboard/presentation/doctor_requests_screen.dart';
import '../features/dashboard/presentation/admin_dashboard_screen.dart';
import '../features/dashboard/presentation/request_transfer_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/tos_screen.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingRepo = ref.watch(onboardingRepositoryProvider);
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const _AuthGuard(child: DashboardScreen()),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const BasicPatientProfileScreen(),
      ),
      GoRoute(
        path: '/monitoring',
        builder: (context, state) {
          final patientIdStr = state.uri.queryParameters['patientId'];
          final patientId = int.tryParse(patientIdStr ?? '');
          return MonitoringScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: '/records',
        builder: (context, state) => const RecordsScreen(),
        routes: [
          GoRoute(
            path: ':recordId',
            builder: (context, state) {
              final idStr = state.pathParameters['recordId'];
              final id = int.tryParse(idStr ?? ''); // error handling if null
              if (id == null)
                return const Scaffold(body: Center(child: Text("Invalid ID")));
              return RecordDetailScreen(recordId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/patients',
        builder: (context, state) => const DoctorPatientsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = int.tryParse(idStr ?? '');
              return RecordsScreen(patientId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/requests',
        builder: (context, state) => const DoctorRequestsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/transfer-request',
        builder: (context, state) => const RequestTransferScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/tos', builder: (context, state) => const TosScreen()),
    ],
    redirect: (context, state) {
      final path = state.uri.path;

      // 0. Splash Exception
      if (path == '/splash') return null;

      // 1. Onboarding Check
      if (!onboardingRepo.hasSeenOnboarding) {
        if (path != '/onboarding') return '/onboarding';
        return null; // Stay on onboarding
      }

      // 2. ToS Check
      if (!onboardingRepo.hasAcceptedTos) {
        if (path != '/tos') return '/tos';
        return null; // Stay on ToS
      }

      // 3. Auth Check
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = path == '/login' || path == '/register';

      if (session == null) {
        if (!isAuthRoute) return '/login';
        return null;
      }

      if (isAuthRoute) {
        return '/';
      }

      return null;
    },
  );
});

class _AuthGuard extends StatefulWidget {
  final Widget child;
  const _AuthGuard({required this.child});

  @override
  State<_AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<_AuthGuard> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        if (mounted) context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
