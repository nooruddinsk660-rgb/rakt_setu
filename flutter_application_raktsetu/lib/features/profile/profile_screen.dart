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
  @override
  void initState() {
    super.initState();
    // Refresh user data on load
    Future.microtask(() => ref.read(currentUserProvider.notifier).refresh());
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
                  items:
                      [
                            AppRole.manager,
                            AppRole.hr,
                            AppRole.helpline,
                            AppRole.hospital,
                          ]
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

  void _showEditProfileDialog(BuildContext context, AppUser user) {
    final nameController = TextEditingController(text: user.name);
    final cityController = TextEditingController(text: user.city);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(ctx);
                await ref
                    .read(userRepositoryProvider)
                    .updateProfile(
                      name: nameController.text.trim(),
                      city: cityController.text.trim(),
                      phone: phoneController.text.trim(),
                    );
                await ref.read(currentUserProvider.notifier).refresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account Security'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.password),
              title: Text('Change Password'),
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: Icon(Icons.phonelink_setup),
              title: Text('Two-Factor Authentication'),
              subtitle: Text('Coming soon'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = AppRole.fromJson(user.role);

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
        actions: [
          TextButton(
            onPressed: () => _showEditProfileDialog(context, user),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileInfoCard(
              name: user.name,
              role: role.displayName,
              location: '${user.city ?? 'Location not set'}, IN',
              email: user.email,
              imageUrl:
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&background=random',
              onEdit: () => _showEditProfileDialog(context, user),
            ),
            const SizedBox(height: 12),
            if (user.phone != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      user.phone!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AvailabilitySwitch(
                value: user.availabilityStatus ?? true,
                onChanged: (value) async {
                  try {
                    await ref
                        .read(userRepositoryProvider)
                        .updateProfile(availabilityStatus: value);
                    await ref.read(currentUserProvider.notifier).refresh();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                    }
                  }
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
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Schedule feature coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ProfileMenuItem(
                          title: 'Dark Mode',
                          icon: Icons.dark_mode,
                          onTap: () {},
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
                          onTap: () => _showSecurityDialog(context),
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
                            await ref
                                .read(authNotifierProvider.notifier)
                                .logout();
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
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Future.microtask(() => context.go('/dashboard'));
          if (index == 1) {
            final r = role.toJson();
            if (r == 'ADMIN' || r == 'VOLUNTEER') {
              context.go('/helpline');
            } else {
              context.go('/dashboard'); // Fallback or specific role requests
            }
          }
          if (index == 2) Future.microtask(() => context.go('/notifications'));
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
