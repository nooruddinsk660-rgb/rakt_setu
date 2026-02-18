import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/components/app_button.dart'; // Though not strictly used, good to have if we replace buttons
import '../../core/constants/role_constants.dart';
import 'widgets/availability_switch.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_menu_item.dart';
import 'user_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = 'Loading...';
  String _email = '';
  AppRole _role = AppRole.volunteer;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final storage = ref.read(secureStorageProvider);
    final userData = await storage.getUser();
    final roleStr = await storage.getRole();
    if (mounted) {
      setState(() {
        _name = userData['name'] ?? 'User';
        _email = userData['email'] ?? '';
        _role = AppRole.fromJson(roleStr ?? '');
      });
    }
  }

  void _showRoleRequestDialog(BuildContext context) {
    AppRole? selectedRole;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Request Role Upgrade'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select the role you wish to apply for:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Role',
                  ),
                  items: [AppRole.manager, AppRole.hr, AppRole.helpline]
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedRole = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () async {
                        try {
                          Navigator.pop(context); // Close dialog
                          // Implement call
                          await ref
                              .read(userRepositoryProvider)
                              .requestRole(selectedRole!.toJson());

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Request for ${selectedRole?.displayName} submitted!',
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                child: const Text('Submit Request'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Future.microtask(() => context.go('/dashboard'));
            }
          },
        ),
        title: const Text('Profile & Settings'),
        actions: [TextButton(onPressed: () {}, child: const Text('Edit'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileInfoCard(
              name: _name,
              role: _role.displayName,
              location:
                  'Kolkata, IN', // Placeholder for now, or fetch from storage if added
              email: _email,
              imageUrl:
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_name)}&background=random',
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
                          onTap: () => Future.microtask(
                            () => context.go('/notifications'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ... (rest of account section) ...
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
                          title: 'Request Role Upgrade',
                          icon: Icons.upgrade,
                          onTap: () => _showRoleRequestDialog(context),
                        ),
                        const Divider(height: 1),
                        ProfileMenuItem(
                          title: 'Log Out',
                          icon: Icons.logout,
                          isDestructive: true,
                          onTap: () async {
                            await ref.read(authRepositoryProvider).logout();
                            if (context.mounted) {
                              Future.microtask(() => context.go('/login'));
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
          if (index == 0) Future.microtask(() => context.go('/dashboard'));
          if (index == 1)
            Future.microtask(
              () => context.go('/helpline'),
            ); // Or operations/donors depending on role
          if (index == 2) Future.microtask(() => context.go('/notifications'));
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
