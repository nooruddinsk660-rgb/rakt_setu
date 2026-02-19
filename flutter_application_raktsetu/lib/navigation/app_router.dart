import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/storage/secure_storage.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/account_locked_screen.dart';
import '../features/auth/account_locked_screen.dart';
import '../features/auth/auth_provider.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/donor/donor_directory_screen.dart';
import '../features/helpline/helpline_screen.dart';
import '../features/camp/camp_screen.dart';
import '../features/camp/camp_list_screen.dart';
import '../features/camp/camp_list_screen.dart';
import '../features/outreach/outreach_screen.dart';
import '../features/splash/splash_screen.dart'; // Import SplashScreen
import '../features/hr/hr_screen.dart';
import '../features/hr/add_team_member_screen.dart';
import '../features/operations/operations_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/dashboard/roles/create_request_screen.dart';
import '../features/dashboard/roles/blood_stock_screen.dart';
import '../features/dashboard/roles/hospital_request_screen.dart';
import '../features/dashboard/roles/admin/approval_queue_screen.dart';
import '../features/dashboard/roles/admin/user_management_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  // This logic works but ideally we listen to a Stream of auth status
  // For simplicity using the secure storage token check in redirect

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/account-locked',
        builder: (context, state) => const AccountLockedScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/donors',
        builder: (context, state) => const DonorDirectoryScreen(),
      ),
      GoRoute(
        path: '/helpline',
        builder: (context, state) => const HelplineScreen(),
      ),
      GoRoute(
        path: '/camps',
        builder: (context, state) => const CampListScreen(),
      ),
      GoRoute(
        path: '/camp-details',
        builder: (context, state) {
          final camp = state.extra as Map<String, dynamic>? ?? {};
          return CampScreen(camp: camp);
        },
      ),
      GoRoute(
        path: '/outreach',
        builder: (context, state) => const OutreachScreen(),
      ),
      GoRoute(
        path: '/hr',
        builder: (context, state) => const HRScreen(),
        routes: [
          GoRoute(
            path: 'add-member',
            builder: (context, state) => const AddTeamMemberScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/operations',
        builder: (context, state) => const OperationsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/create-request',
        builder: (context, state) => const CreateRequestScreen(),
      ),
      GoRoute(
        path: '/blood-stock',
        builder: (context, state) => const BloodStockScreen(),
      ),
      GoRoute(
        path: '/hospital-request',
        builder: (context, state) => const HospitalRequestScreen(),
      ),
      GoRoute(
        path: '/admin/approvals',
        builder: (context, state) => const ApprovalQueueScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
    redirect: (context, state) async {
      // Simple redirect logic
      // In a real app this should check SecureStorage sync or allow auth provider to notify
      final storage = SecureStorage();
      final token = await storage.getToken();
      final isLoggingIn = state.uri.toString() == '/login';
      final isRecovering =
          state.uri.toString() == '/forgot-password' ||
          state.uri.toString() == '/account-locked';
      final isSigningUp = state.uri.toString() == '/signup';
      final isSplashing = state.uri.toString() == '/splash';

      if (token == null) {
        return (isLoggingIn || isRecovering || isSigningUp || isSplashing)
            ? null
            : '/login';
      }

      if (isLoggingIn || isSigningUp || isSplashing) {
        return '/dashboard';
      }

      return null;
    },
  );
});
