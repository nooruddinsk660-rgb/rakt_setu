import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/components/app_card.dart';
import '../../widgets/request_status_card.dart';

class HospitalHomeTab extends StatelessWidget {
  const HospitalHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.add_alert,
                  title: 'Post Emergency',
                  color: Colors.red,
                  onTap: () => context.push('/hospital-request'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: Icons.bloodtype,
                  title: 'Manage Stock',
                  color: Colors.blue,
                  onTap: () => context.push('/blood-stock'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Active Requests',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Mock Data
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return RequestStatusCard(
                requestId: 'REQ-H-${2000 + index}',
                bloodGroup: index == 0 ? 'AB-' : 'O+',
                units: index == 0 ? 4 : 2,
                hospitalName: 'Your Hospital',
                status: index == 0
                    ? RequestStatus.pending
                    : RequestStatus.accepted,
                timeAgo: '${index * 2 + 1}h ago',
                donorCount: index == 0 ? 0 : 5,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
