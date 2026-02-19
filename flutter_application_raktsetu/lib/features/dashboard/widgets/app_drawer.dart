import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../../../core/constants/role_constants.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = user?.role.toUpperCase() ?? '';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.bloodtype, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'RaktSetu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user != null)
                  Text(
                    'Hello, ${user.name}',
                    style: const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              context.pop();
              context.go('/dashboard');
            },
          ),

          // Role-based Menu Items
          if (role == AppRole.admin.toJson() ||
              role == AppRole.manager.toJson() ||
              role == AppRole.hr.toJson() ||
              role == AppRole.volunteer.toJson()) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                'Administration',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Operations Hub'),
              onTap: () {
                context.pop();
                context.go('/operations');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('HR & Team'),
              onTap: () {
                context.pop();
                context.go('/hr');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('Outreach'),
              onTap: () {
                context.pop();
                context.go('/outreach');
              },
            ),
          ],

          if (role == AppRole.admin.toJson() ||
              role == AppRole.hospital.toJson() ||
              role == AppRole.volunteer.toJson()) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Blood Camps'),
              onTap: () {
                context.pop();
                context.go('/camps');
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Helpline Requests'),
              onTap: () {
                context.pop();
                context.go('/helpline');
              },
            ),
          ],

          // Common Items
          const Divider(),
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('Donor Directory'),
            onTap: () {
              context.pop();
              context.go('/donors');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              context.pop();
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
