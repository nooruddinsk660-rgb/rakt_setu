import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_button.dart';
import 'widgets/hub_metric_card.dart';
import 'widgets/quick_action_item.dart';
import 'widgets/recent_activity_item.dart';
import 'operations_provider.dart';
import '../auth/auth_provider.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/constants/role_constants.dart';

class OperationsScreen extends ConsumerWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(operationsOverviewProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Better background
      appBar: AppBar(
        title: const Text('Operations Hub'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Future.microtask(() => context.go('/dashboard'));
            }
          },
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(operationsOverviewProvider),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (User Info)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://ui-avatars.com/api/?name=Manager&background=random',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userAsync != null
                                  ? AppRole.fromJson(
                                      userAsync.role,
                                    ).displayName.toUpperCase()
                                  : 'STAFF',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userAsync?.name ?? 'Operations Manager',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, // Settings or Profile link
                        icon: const Icon(Icons.settings_outlined),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Loaded Data
                statsAsync.when(
                  data: (stats) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overview',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Metrics Grid
                      Row(
                        children: [
                          Expanded(
                            child: HubMetricCard(
                              title: 'Assigned Camps',
                              value: (stats['assignedCamps'] ?? 0).toString(),
                              subValue: 'Active',
                              icon: Icons.campaign,
                              color: Colors.green,
                              badgeText: 'Active',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: HubMetricCard(
                              title: 'Workflow',
                              value: (stats['workflowUrgent'] ?? 0).toString(),
                              subValue: 'Urgent',
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HubMetricCard(
                              title: 'Pending Pay',
                              value: '₹${stats['pendingPay'] ?? 0}',
                              icon: Icons.payments,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Access Denied or Server Error. \nEnsure you have Manager permissions.',
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuickActionItem(
                        label: 'New Camp',
                        icon: Icons.add_location_alt,
                        onTap: () {
                          Future.microtask(
                            () => context.go('/camps'),
                          ); // Navigate to Camp List
                        },
                      ),
                      QuickActionItem(
                        label: 'Inventory',
                        icon: Icons.inventory_2,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Inventory Module: Feature Coming Soon',
                              ),
                            ),
                          );
                        },
                      ),
                      QuickActionItem(
                        label: 'Volunteer',
                        icon: Icons.group_add,
                        onTap: () {
                          Future.microtask(() => context.go('/hr'));
                        },
                      ),
                      QuickActionItem(
                        label: 'Reports',
                        icon: Icons.bar_chart,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reports Module: Feature Coming Soon',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
