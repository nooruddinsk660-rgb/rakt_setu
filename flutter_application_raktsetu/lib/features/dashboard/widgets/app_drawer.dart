import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.bloodtype, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'RaktSetu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              context.pop(); // Close drawer
              context.go('/dashboard');
            },
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
            leading: const Icon(Icons.campaign),
            title: const Text('Outreach Information'),
            onTap: () {
              context.pop();
              context.go('/outreach');
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              context.pop();
              context.go('/profile');
            },
          ),
        ],
      ),
    );
  }
}
