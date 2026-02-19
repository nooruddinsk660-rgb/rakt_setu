import 'package:flutter/material.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_button.dart';

enum RequestUrgency { critical, high, moderate, low }

class BloodRequestCard extends StatelessWidget {
  final String patientName;
  final String hospitalName;
  final String distance;
  final String bloodGroup;
  final RequestUrgency urgency;
  final String timeAgo;
  final VoidCallback onAccept;
  final VoidCallback onIgnore;

  const BloodRequestCard({
    super.key,
    required this.patientName,
    required this.hospitalName,
    required this.distance,
    required this.bloodGroup,
    required this.urgency,
    required this.timeAgo,
    required this.onAccept,
    required this.onIgnore,
  });

  Color _getUrgencyColor() {
    switch (urgency) {
      case RequestUrgency.critical:
        return Colors.red;
      case RequestUrgency.high:
        return Colors.orange;
      case RequestUrgency.moderate:
        return Colors.yellow.shade700;
      case RequestUrgency.low:
        return Colors.green;
    }
  }

  String _getUrgencyLabel() {
    return urgency.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgencyColor = _getUrgencyColor();

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: urgencyColor.withOpacity(0.5)),
                ),
                child: Text(
                  _getUrgencyLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: urgencyColor,
                  ),
                ),
              ),
              Text(
                timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  bloodGroup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(hospitalName, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onIgnore,
                  child: const Text('Ignore'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(text: 'Accept', onPressed: onAccept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
