import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/app_drawer.dart';
import 'dashboard_provider.dart';
import 'widgets/metric_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/performance_chart.dart';
import 'widgets/recent_activity_list.dart';
import '../../shared/providers/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

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
            child: ref
                .watch(dashboardStatsProvider)
                .when(
                  data: (stats) => SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI Cards
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
                                'Updated 2m ago',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Key Metrics Row
                        SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              MetricCard(
                                title: 'Active Helplines',
                                value:
                                    stats['activeHelplines']?.toString() ?? '0',
                                icon: Icons.support_agent,
                                color: Theme.of(context).primaryColor,
                                trend: '+2', // TODO: Calculate trend
                                isPositiveTrend: false,
                              ),
                              const SizedBox(width: 16),
                              MetricCard(
                                title: 'Total Volunteers',
                                value:
                                    stats['totalVolunteers']?.toString() ?? '0',
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

                        // Quick Actions
                        QuickActionGrid(
                          onBroadcastTap: () {
                            // TODO: Implement Broadcast Alert
                          },
                          onApproveTap: () {
                            // TODO: Implement Approve Request
                          },
                        ),

                        const SizedBox(height: 24),

                        // Performance Chart
                        PerformanceChart(
                          data: stats['campsPerCity'] as List<dynamic>?,
                        ),

                        const SizedBox(height: 24),

                        // Recent Activity
                        RecentActivityList(
                          data: stats['recentRequests'] as List<dynamic>?,
                        ),

                        // Bottom spacing for FAB or bottom nav
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Text(
                      'Error loading stats: $err',
                      style: const TextStyle(color: Colors.red),
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
            // Already on Dashboard
          } else if (index == 1) {
            context.go('/donors');
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
            label: 'Volunteers',
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
