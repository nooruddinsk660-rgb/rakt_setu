import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/dashboard_header.dart';
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
            child: SingleChildScrollView(
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
                    height: 140, // Height for cards
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        MetricCard(
                          title: 'Response Time',
                          value: '12m',
                          icon: Icons.timer,
                          color: Colors.purple,
                          trend: '-2m',
                          isPositiveTrend: true, // Lower is better
                        ),
                        // Add more MetricCards here
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
                  const PerformanceChart(),

                  const SizedBox(height: 24),

                  // Recent Activity
                  const RecentActivityList(),

                  // Bottom spacing for FAB or bottom nav
                  const SizedBox(height: 80),
                ],
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
