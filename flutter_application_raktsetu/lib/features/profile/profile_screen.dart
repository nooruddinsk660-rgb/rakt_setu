import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/components/app_button.dart'; // Though not strictly used, good to have if we replace buttons
import 'widgets/availability_switch.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [TextButton(onPressed: () {}, child: const Text('Edit'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileInfoCard(
              name: 'Sarah Jenkins', // Mock data
              role: 'Regional Manager',
              location: 'New York, NY',
              email: 'sarah.j@bloodconnect.org',
              imageUrl:
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCCzk1rVFKOphln0GQSWaSm6fuUGOCO25ezbn3CyvxDqpSqsmuDAa_rfwWWEtdHUGro9YOYrmhK_W9qvHIKcswnOumPXDdxhtLN1UEgdtNhhA0q10qAGwv9vpJt5IGUWaNXU6Hv8FQvh3CReCCIG8slr0syJoy2B2B98erPDNo0YL2eSpCgjRsHT3jRnw7b3lZWQWqGbaectOFqUZaMdQ0fVPfeql0XhQoW-mtUVbHDRxrkKdEqDhQYxlvtO63onL_irY-qLRao10-d',
              onEdit: () {},
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AvailabilitySwitch(
                value: _isAvailable,
                onChanged: (value) {
                  setState(() => _isAvailable = value);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Preferences
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREFERENCES',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          title: 'My Schedule',
                          icon: Icons.calendar_month,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ProfileMenuItem(
                          title: 'Dark Mode',
                          icon: Icons.dark_mode,
                          onTap:
                              () {}, // Tap handled by switch usually, but let's keep it interactive
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              ref.read(themeModeProvider.notifier).state = value
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        ProfileMenuItem(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          onTap: () => context.go('/notifications'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          title: 'Security',
                          icon: Icons.lock,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ProfileMenuItem(
                          title: 'Log Out',
                          icon: Icons.logout,
                          isDestructive: true,
                          onTap: () async {
                            await ref.read(authRepositoryProvider).logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Text(
              'Version 2.4.0 (Build 184)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1)
            context.go('/helpline'); // Or operations/donors depending on role
          if (index == 2) context.go('/notifications');
          // index 3 is current
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
