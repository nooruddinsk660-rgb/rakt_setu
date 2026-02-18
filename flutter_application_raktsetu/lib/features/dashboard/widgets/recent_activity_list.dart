import 'package:flutter/material.dart';
import '../../../shared/components/app_card.dart';

class RecentActivityList extends StatelessWidget {
  final List<dynamic>? data;

  const RecentActivityList({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final activities = data ?? [];

    if (activities.isEmpty) {
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
          const AppCard(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No recent activity to show')),
            ),
          ),
        ],
      );
    }

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
        ...activities.map((activity) {
          // Activity is a HelplineRequest
          final type = '${activity['bloodGroup'] ?? 'Blood'} Request';
          final status = activity['status'] ?? 'Pending';
          final location = activity['city'] ?? 'Unknown';
          final createdAt = activity['createdAt'] as String?;

          // Simple time ago logic
          String timeAgo = 'Just now';
          if (createdAt != null) {
            final date = DateTime.tryParse(createdAt);
            if (date != null) {
              final diff = DateTime.now().difference(date);
              if (diff.inMinutes < 60) {
                timeAgo = '${diff.inMinutes}m ago';
              } else if (diff.inHours < 24) {
                timeAgo = '${diff.inHours}h ago';
              } else {
                timeAgo = '${diff.inDays}d ago';
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActivityItem(
              context,
              icon: Icons.bloodtype, // TODO: Map icon based on type
              iconColor: _getStatusColor(status),
              title: '$type Request',
              subtitle: '$location • $timeAgo',
              trailing: _getStatusIcon(status),
            ),
          );
        }),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'inprogress':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green, size: 16);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.grey, size: 16);
      default:
        return const Icon(Icons.chevron_right, color: Colors.grey);
    }
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
