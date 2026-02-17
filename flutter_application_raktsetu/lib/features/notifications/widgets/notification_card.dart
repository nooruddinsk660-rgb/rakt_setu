import 'package:flutter/material.dart';

enum NotificationType {
  escalation,
  helpline,
  reimbursement,
  announcement,
  missedCall,
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeAgo;
  final NotificationType type;
  final bool isUnread;
  final List<String>? tags;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isUnread = false,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color iconColor;
    Color iconBgColor;
    IconData icon;

    switch (type) {
      case NotificationType.escalation:
        iconColor = theme.primaryColor;
        iconBgColor = theme.primaryColor.withOpacity(0.1);
        icon = Icons.warning;
        break;
      case NotificationType.helpline:
        iconColor = Colors.blue;
        iconBgColor = Colors.blue.withOpacity(0.1);
        icon = Icons.call;
        break;
      case NotificationType.reimbursement:
        iconColor = Colors.green;
        iconBgColor = Colors.green.withOpacity(0.1);
        icon = Icons.payments;
        break;
      case NotificationType.announcement:
        iconColor = Colors.orange;
        iconBgColor = Colors.orange.withOpacity(0.1);
        icon = Icons.campaign;
        break;
      case NotificationType.missedCall:
        iconColor = Colors.grey;
        iconBgColor = Colors.grey.withOpacity(0.2);
        icon = Icons.call_missed;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? theme.cardColor
            : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: isUnread
              ? BorderSide(color: theme.primaryColor, width: 4)
              : BorderSide.none,
          top: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          right: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (isUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight
                                        .w600, // Slightly bolder if unread
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Space for dot
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
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tags != null && tags!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Wrap(
                          spacing: 8,
                          children: tags!
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
