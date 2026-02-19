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
    final user = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(operationsOverviewProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = AppRole.fromJson(user.role);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${role.displayName} Operations'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: theme.textTheme.titleLarge?.color,
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
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}&background=random',
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
                              role.displayName.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/profile'),
                        icon: const Icon(Icons.person_outline),
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Loaded Data
                statsAsync.when(
                  data: (stats) => _buildRoleMetrics(context, role, stats),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) =>
                      _buildErrorCard(context, err.toString()),
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
                _buildQuickActions(context, role),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleMetrics(
    BuildContext context,
    AppRole role,
    Map<String, dynamic> stats,
  ) {
    List<Widget> cards = [];

    if (role == AppRole.admin) {
      cards = [
        _metricRow([
          _metric(
            context,
            'Total Users',
            stats['totalUsers'],
            Icons.people,
            Colors.blue,
          ),
          _metric(
            context,
            'Total Camps',
            stats['totalCamps'],
            Icons.campaign,
            Colors.green,
          ),
        ]),
        const SizedBox(height: 12),
        _metricRow([
          _metric(
            context,
            'Active Req',
            stats['activeRequests'],
            Icons.assignment,
            Colors.orange,
          ),
          _metric(
            context,
            'Verifications',
            stats['verificationPending'],
            Icons.verified_user,
            Colors.purple,
          ),
        ]),
      ];
    } else if (role == AppRole.manager) {
      cards = [
        HubMetricCard(
          title: 'Assigned Camps',
          value: (stats['assignedCamps'] ?? 0).toString(),
          subValue: 'Active Today',
          icon: Icons.campaign,
          color: Colors.green,
          badgeText: 'Live',
        ),
        const SizedBox(height: 12),
        _metricRow([
          _metric(
            context,
            'Critical Req',
            stats['workflowUrgent'],
            Icons.warning,
            Colors.red,
          ),
          _metric(
            context,
            'Pending Pay',
            '₹${stats['pendingPay'] ?? 0}',
            Icons.payments,
            Colors.blue,
          ),
        ]),
      ];
    } else if (role == AppRole.hr) {
      cards = [
        _metricRow([
          _metric(
            context,
            'Volunteers',
            stats['totalVolunteers'],
            Icons.groups,
            Colors.indigo,
          ),
          _metric(
            context,
            'Online Now',
            stats['onlineVolunteers'],
            Icons.circle,
            Colors.green,
          ),
        ]),
        const SizedBox(height: 12),
        _metricRow([
          _metric(
            context,
            'Upgrades',
            stats['newRoleRequests'],
            Icons.upgrade,
            Colors.orange,
          ),
          _metric(
            context,
            'Interviews',
            stats['pendingInterview'],
            Icons.event,
            Colors.blue,
          ),
        ]),
      ];
    } else {
      // Volunteer or others
      cards = [
        _metricRow([
          _metric(
            context,
            'My Tasks',
            stats['myTasks'],
            Icons.task_alt,
            Colors.blue,
          ),
          _metric(
            context,
            'Completed',
            stats['completedTasks'],
            Icons.done_all,
            Colors.green,
          ),
        ]),
        const SizedBox(height: 12),
        _metricRow([
          _metric(
            context,
            'Upcoming Camps',
            stats['upcomingCamps'],
            Icons.event,
            Colors.orange,
          ),
          _metric(
            context,
            'New Msg',
            stats['messages'],
            Icons.mail,
            Colors.purple,
          ),
        ]),
      ];
    }

    return Column(children: cards);
  }

  Widget _metricRow(List<Widget> children) {
    return Row(
      children:
          children
              .expand((w) => [Expanded(child: w), const SizedBox(width: 12)])
              .toList()
            ..removeLast(),
    );
  }

  Widget _metric(
    BuildContext context,
    String title,
    dynamic value,
    IconData icon,
    Color color,
  ) {
    return HubMetricCard(
      title: title,
      value: (value ?? 0).toString(),
      icon: icon,
      color: color,
    );
  }

  Widget _buildQuickActions(BuildContext context, AppRole role) {
    final List<QuickActionItem> actions = [];

    if (role == AppRole.admin) {
      actions.addAll([
        QuickActionItem(
          label: 'All Users',
          icon: Icons.person_search,
          onTap: () => context.push('/hr'),
        ),
        QuickActionItem(
          label: 'Camp Admin',
          icon: Icons.map,
          onTap: () => context.push('/camps'),
        ),
        QuickActionItem(
          label: 'Inventory',
          icon: Icons.inventory,
          onTap: () => _showComingSoon(context),
        ),
        QuickActionItem(
          label: 'System Log',
          icon: Icons.terminal,
          onTap: () => _showComingSoon(context),
        ),
      ]);
    } else if (role == AppRole.manager) {
      actions.addAll([
        QuickActionItem(
          label: 'Manage Camps',
          icon: Icons.location_on,
          onTap: () => context.push('/camps'),
        ),
        QuickActionItem(
          label: 'Inventory',
          icon: Icons.storage,
          onTap: () => _showComingSoon(context),
        ),
        QuickActionItem(
          label: 'Helpline',
          icon: Icons.support_agent,
          onTap: () => context.push('/helpline'),
        ),
        QuickActionItem(
          label: 'Payment Appr',
          icon: Icons.payments,
          onTap: () => context.push('/reimbursement-approval'),
        ),
      ]);
    } else if (role == AppRole.hr) {
      actions.addAll([
        QuickActionItem(
          label: 'Volunteer List',
          icon: Icons.people,
          onTap: () => context.push('/hr'),
        ),
        QuickActionItem(
          label: 'Verify Users',
          icon: Icons.how_to_reg,
          onTap: () => _showComingSoon(context),
        ),
        QuickActionItem(
          label: 'Performance',
          icon: Icons.insights,
          onTap: () => _showComingSoon(context),
        ),
        QuickActionItem(
          label: 'Payment Appr',
          icon: Icons.payments,
          onTap: () => context.push('/reimbursement-approval'),
        ),
      ]);
    } else {
      actions.addAll([
        QuickActionItem(
          label: 'My Tasks',
          icon: Icons.assignment_turned_in,
          onTap: () => context.push('/helpline'),
        ),
        QuickActionItem(
          label: 'Available Camps',
          icon: Icons.event_available,
          onTap: () => context.push('/camps'),
        ),
        QuickActionItem(
          label: 'Reimbursement',
          icon: Icons.account_balance_wallet,
          onTap: () => context.push('/reimbursements'),
        ),
        QuickActionItem(
          label: 'Leaderboard',
          icon: Icons.emoji_events,
          onTap: () => _showComingSoon(context),
        ),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Module Coming Soon: We are working hard to build this!'),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
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
              'Error loading dashboard: $message',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.red[300]
                    : Colors.red[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
