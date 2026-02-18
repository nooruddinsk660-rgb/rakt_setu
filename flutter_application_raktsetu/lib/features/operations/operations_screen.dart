import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_button.dart';
import 'widgets/hub_metric_card.dart';
import 'widgets/quick_action_item.dart';
import 'widgets/recent_activity_item.dart';

class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAi3X1SujkZ2aWiJ4kZ4D3DLVqtIC40NKhEe9HX1KMW8Um1KqR_nm_ZrTT0lFDHJ4LtNSy5Va4YprE5KveGaDx1YvJ4nj8AYv9tSNaQQG8B2PMuxaMIrQrc7uAwx4bAEFvcJThDqX1vsOv_SlLSlTGwbKO9YIE_NcxsFjcnkjKmBbSq5lZIXAxi6DGFexza2OIDZcEzJlkLDrdOSGHLwhmdNUWKvabIbbpERODxd-lCeVHE25cggndWmdGEWnonCHMYGW6sG0s0hrgF',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MANAGER',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Rahul Sharma',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Overview
              Text(
                'Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Operations status for Oct 24, 2023',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 16),

              // Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: HubMetricCard(
                      title: 'Assigned Camps',
                      value: '3',
                      subValue: 'Active',
                      icon: Icons.campaign,
                      color: Colors.green,
                      badgeText: '+1 Today',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: HubMetricCard(
                      title: 'Workflow',
                      value: '12',
                      subValue: 'Urgent',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: HubMetricCard(
                      title: 'Pending Pay',
                      value: '₹ 4.5k',
                      icon: Icons.payments,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuickActionItem(
                    label: 'New Camp',
                    icon: Icons.add,
                    onTap: () {
                      // Add Camp navigation possibly
                    },
                  ),
                  QuickActionItem(
                    label: 'Inventory',
                    icon: Icons.inventory_2,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Volunteer',
                    icon: Icons.group_add,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Report',
                    icon: Icons.description,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('View All')),
                ],
              ),

              RecentActivityItem(
                title: 'Camp #102 Completed',
                description:
                    'Rohini Sector 14 drive marked as success. 45 units collected.',
                timeAgo: '10m',
                type: ActivityType.success,
              ),
              RecentActivityItem(
                title: 'Reimbursement Request',
                description: 'Volunteer Amit requested ₹350 for travel.',
                timeAgo: '1h',
                type: ActivityType.info,
                onApprove: () {},
                onDecline: () {},
              ),
              RecentActivityItem(
                title: 'Low Inventory Alert',
                description:
                    'Refreshment kits (Type B) running low at Warehouse 2.',
                timeAgo: '2h',
                type: ActivityType.warning,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0, // Operations Hub
        onDestinationSelected: (index) {
          if (index == 0) {
            // Already on Hub
          } else if (index == 1) {
            context.go('/camp-details'); // Or a camps list if we had one
          } else if (index == 2) {
            context.go('/helpline');
          } else if (index == 3) {
            context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Hub'),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Camps',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
