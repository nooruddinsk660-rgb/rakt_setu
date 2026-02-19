import 'package:flutter/material.dart';
import '../../../../shared/components/app_card.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final users = List.generate(
      5,
      (index) => {
        'name': 'User ${index + 1}',
        'role': index % 2 == 0 ? 'Donor' : 'N/A',
        'status': index == 0 ? 'Blocked' : 'Active',
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isBlocked = user['status'] == 'Blocked';

          return AppCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isBlocked ? Colors.red : Colors.green,
                child: Icon(
                  isBlocked ? Icons.block : Icons.check,
                  color: Colors.white,
                ),
              ),
              title: Text(user['name'] as String),
              subtitle: Text('Role: ${user['role']}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(isBlocked ? 'Unblock' : 'Block'),
                    onTap: () {
                      // TODO: Handle block/unblock
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
