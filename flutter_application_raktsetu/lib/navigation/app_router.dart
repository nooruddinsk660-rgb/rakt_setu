import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/storage/secure_storage.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/account_locked_screen.dart';
import '../features/auth/account_locked_screen.dart';
import '../features/auth/auth_provider.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/donor/donor_directory_screen.dart';
import '../features/helpline/helpline_screen.dart';
import '../features/camp/camp_screen.dart';
import '../features/outreach/outreach_screen.dart';
import '../features/hr/hr_screen.dart';
import '../features/operations/operations_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/profile/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  // This logic works but ideally we listen to a Stream of auth status
  // For simplicity using the secure storage token check in redirect

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
        path: '/camp-details',
        builder: (context, state) => const CampScreen(),
      ),
      GoRoute(
        path: '/outreach',
        builder: (context, state) => const OutreachScreen(),
      ),
      GoRoute(path: '/hr', builder: (context, state) => const HRScreen()),
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

      if (token == null) {
        return (isLoggingIn || isRecovering) ? null : '/login';
      }

      if (isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
  );
});
