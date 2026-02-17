import 'package:flutter/material.dart';

enum ActivityType { success, warning, info }

class RecentActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String timeAgo;
  final ActivityType type;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  const RecentActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.onApprove,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color iconColor;
    Color bgColor;
    IconData icon;

    switch (type) {
      case ActivityType.success:
        iconColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        icon = Icons.check_circle;
        break;
      case ActivityType.warning:
        iconColor = theme.primaryColor;
        bgColor = theme.primaryColor.withOpacity(0.1);
        icon = Icons
            .warning; // or receipt_long for reimbursement, using warning for generic 'alert' look or specific logic
        break;
      case ActivityType.info:
        iconColor = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
        icon = Icons.receipt_long;
        break;
    }

    // Specific override for reimbursement based on context,
    // but let's stick to the mapped types for simplicity.
    // If it's a reimbursement request (info/warning), we show buttons.

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                width: 2,
                height: 40, // Fixed height connector or calculated
                color: theme.dividerColor.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (onApprove != null && onDecline != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: onApprove,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Approve',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: onDecline,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: BorderSide(color: theme.dividerColor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Decline',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
