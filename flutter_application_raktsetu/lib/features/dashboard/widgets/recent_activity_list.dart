import 'package:flutter/material.dart';
import '../../../shared/components/app_card.dart';

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          context,
          icon: Icons.bloodtype,
          iconColor: Colors.red,
          title: 'Urgent A+ Request in Sector 4',
          subtitle: 'Assigned to: Ravi Kumar • 5m ago',
          trailing: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          icon: Icons.person_add,
          iconColor: Colors.blue,
          title: 'New Volunteer Registration',
          subtitle: 'Pending Approval • 25m ago',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          icon: Icons.check_circle,
          iconColor: Colors.green,
          title: 'Donation Drive Completed',
          subtitle: 'Mumbai Central • 2h ago',
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
