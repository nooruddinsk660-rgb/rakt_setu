import 'package:flutter/material.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_button.dart';

enum UrgencyLevel { critical, high, moderate, low, fulfilled }

class HelplineRequestCard extends StatelessWidget {
  final String patientName;
  final String hospital;
  final String timeAgo;
  final String bloodGroup;
  final String statusText;
  final UrgencyLevel urgency;
  final VoidCallback onCall;
  final VoidCallback onPrimaryAction;
  final String primaryActionLabel;

  const HelplineRequestCard({
    super.key,
    required this.patientName,
    required this.hospital,
    required this.timeAgo,
    required this.bloodGroup,
    required this.statusText,
    required this.urgency,
    required this.onCall,
    required this.onPrimaryAction,
    this.primaryActionLabel = 'Assign Donor',
  });

  Color _getUrgencyColor() {
    switch (urgency) {
      case UrgencyLevel.critical:
        return Colors.red;
      case UrgencyLevel.high:
        return Colors.orange;
      case UrgencyLevel.moderate:
        return Colors.yellow.shade700;
      case UrgencyLevel.fulfilled:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyLabel() {
    switch (urgency) {
      case UrgencyLevel.critical:
        return 'CRITICAL';
      case UrgencyLevel.high:
        return 'HIGH';
      case UrgencyLevel.moderate:
        return 'MODERATE';
      case UrgencyLevel.fulfilled:
        return 'FULFILLED';
      default:
        return 'STANDARD';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final urgencyColor = _getUrgencyColor();

    return AppCard(
      child: Column(
        children: [
          // Header with Urgency Tag
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: urgencyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: urgencyColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (urgency == UrgencyLevel.critical) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _getUrgencyLabel(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: urgencyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blood Group Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      Color.lerp(theme.primaryColor, Colors.black, 0.2)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  bloodGroup,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hospital,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 2,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: urgencyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Call',
                  icon: Icons.call,
                  isOutlined: true,
                  onPressed: onCall,
                  // Reduce height slightly for card
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: primaryActionLabel,
                  onPressed: onPrimaryAction,
                  color: urgency == UrgencyLevel.fulfilled
                      ? Colors.green
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
