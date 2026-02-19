import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../helpline/helpline_provider.dart';
import '../../../helpline/widgets/helpline_request_card.dart';
import '../../../../shared/components/app_loader.dart';
import '../../../../shared/components/app_empty_state.dart';

class RequestsListTab extends ConsumerWidget {
  final bool onlyMyRequests;
  const RequestsListTab({super.key, this.onlyMyRequests = true});

  Future<void> _handleCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    try {
      final Uri url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching call: $e');
    }
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Patient', req['patientName']),
            _detailRow('Hospital', req['hospital']),
            _detailRow('City', req['city']),
            _detailRow('Status', req['status']),
            _detailRow('Blood Group', req['bloodGroup']),
            _detailRow('Units', req['unitsRequired']?.toString()),
            _detailRow('Urgency', req['urgencyLevel']),
            if (req['notes'] != null && req['notes'].toString().isNotEmpty)
              _detailRow('Notes', req['notes']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(
      onlyMyRequests ? myRequestsProvider : helplineRequestsProvider,
    );

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(
        onlyMyRequests ? myRequestsProvider : helplineRequestsProvider,
      ),
      child: requestsAsync.when(
        loading: () => const AppLoader(),
        error: (err, stack) => AppEmptyState(
          message: 'Error loading requests',
          subMessage: err.toString(),
          icon: Icons.error_outline,
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return const AppEmptyState(
              message: 'No requests found',
              subMessage: 'Create a new request to get started',
              icon: Icons.assignment_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final req = requests[index];
              final urgencyStr = req['urgencyLevel'] ?? 'Normal';
              UrgencyLevel urgency;
              if (urgencyStr == 'Critical') {
                urgency = UrgencyLevel.critical;
              } else if (urgencyStr == 'Urgent') {
                urgency = UrgencyLevel.high;
              } else {
                urgency = UrgencyLevel.moderate;
              }

              final status = req['status'] ?? 'Pending';

              // Time Ago Logic
              String timeAgo = 'Just now';
              final createdAt = req['createdAt'] as String?;
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

              return HelplineRequestCard(
                patientName: req['patientName'] ?? 'Unknown',
                hospital: req['hospital'] ?? 'Unknown Hospital',
                timeAgo: timeAgo,
                bloodGroup: req['bloodGroup'] ?? '',
                statusText: status,
                urgency: urgency,
                primaryActionLabel: 'View Details',
                onCall: () => _handleCall(req['phone']),
                onPrimaryAction: () => _showDetailsDialog(context, req),
              );
            },
          );
        },
      ),
    );
  }
}
