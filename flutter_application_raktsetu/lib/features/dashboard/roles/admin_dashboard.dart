import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_drawer.dart';
import '../dashboard_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action_grid.dart';
import '../../../../shared/components/app_card.dart';
import '../widgets/performance_chart.dart';
import '../widgets/recent_activity_list.dart';
import '../../../shared/providers/theme_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      drawer: const AppDrawer(),
      body: Column(
        children: [
          DashboardHeader(
            isDarkMode: isDarkMode,
            onThemeToggle: () {
              ref.read(themeModeProvider.notifier).state = isDarkMode
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                return ref.refresh(dashboardStatsProvider.future);
              },
              child: ref
                  .watch(dashboardStatsProvider)
                  .when(
                    data: (stats) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Live Overview',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Updated just now',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 140,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                MetricCard(
                                  title: 'Active Helplines',
                                  value:
                                      stats['activeHelplines']?.toString() ??
                                      '0',
                                  icon: Icons.support_agent,
                                  color: Theme.of(context).primaryColor,
                                  trend: '+2',
                                  isPositiveTrend: false,
                                ),
                                const SizedBox(width: 16),
                                MetricCard(
                                  title: 'Total Volunteers',
                                  value:
                                      stats['totalVolunteers']?.toString() ??
                                      '0',
                                  icon: Icons.people,
                                  color: Colors.orange,
                                  trend: '+5',
                                  isPositiveTrend: true,
                                ),
                                const SizedBox(width: 16),
                                MetricCard(
                                  title: 'Avg Response',
                                  value:
                                      '${stats['avgResponseTimeMinutes'] ?? 0}m',
                                  icon: Icons.timer,
                                  color: Colors.blue,
                                  trend: '-1m',
                                  isPositiveTrend: true,
                                ),
                                const SizedBox(width: 16),
                                MetricCard(
                                  title: 'Completion Rate',
                                  value: stats['taskCompletionRate'] ?? '0%',
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  trend: '+1%',
                                  isPositiveTrend: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          QuickActionGrid(
                            onBroadcastTap: () {
                              context.push('/outreach');
                            },
                            onApproveTap: () {
                              context.push('/admin/approvals');
                            },
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            onTap: () => context.push('/admin/users'),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.manage_accounts,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'User Management',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          PerformanceChart(
                            data: stats['campsPerCity'] as List<dynamic>?,
                          ),

                          const SizedBox(height: 24),

                          RecentActivityList(
                            data: stats['recentRequests'] as List<dynamic>?,
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error loading stats',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ref.refresh(dashboardStatsProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) {
          } else if (index == 1) {
            context.go('/operations');
          } else if (index == 2) {
            context.go('/helpline');
          } else if (index == 3) {
            context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Operations',
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
