import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/request_status_card.dart';

class PatientHomeTab extends StatelessWidget {
  const PatientHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create-request');
        },
        label: const Text('New Request'),
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Requests',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Mock Data
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return RequestStatusCard(
                  requestId: 'REQ-${1000 + index}',
                  bloodGroup: 'B+',
                  units: 2,
                  hospitalName: 'City Hospital',
                  status: index == 0
                      ? RequestStatus.pending
                      : RequestStatus.accepted,
                  timeAgo: '${index + 1}h ago',
                  donorCount: index == 0 ? 0 : 3,
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Past Requests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            RequestStatusCard(
              requestId: 'REQ-999',
              bloodGroup: 'B+',
              units: 1,
              hospitalName: 'General Hospital',
              status: RequestStatus.fulfilled,
              timeAgo: '2 days ago',
              donorCount: 1,
            ),
          ],
        ),
      ),
    );
  }
}
