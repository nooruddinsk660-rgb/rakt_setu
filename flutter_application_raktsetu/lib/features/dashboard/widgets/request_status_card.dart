import 'package:flutter/material.dart';
import '../../../../shared/components/app_card.dart';

enum RequestStatus { pending, accepted, fulfilled, cancelled }

class RequestStatusCard extends StatelessWidget {
  final String requestId;
  final String bloodGroup;
  final int units;
  final String hospitalName;
  final RequestStatus status;
  final String timeAgo;
  final int donorCount;

  const RequestStatusCard({
    super.key,
    required this.requestId,
    required this.bloodGroup,
    required this.units,
    required this.hospitalName,
    required this.status,
    required this.timeAgo,
    this.donorCount = 0,
  });

  Color _getStatusColor() {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.fulfilled:
        return Colors.green;
      case RequestStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    return status.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request #$requestId',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  _getStatusLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
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
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  bloodGroup,
                  style: const TextStyle(
                    color: Colors.red,
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
                      '$units Units Required',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(hospitalName, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              if (donorCount > 0)
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '$donorCount Donors Responded',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'Waiting for donors...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
