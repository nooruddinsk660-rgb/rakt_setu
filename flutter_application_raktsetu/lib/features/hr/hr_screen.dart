import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_loader.dart';
import '../../shared/components/app_empty_state.dart';
import 'widgets/burnout_warning_card.dart';
import 'widgets/manager_performance_card.dart';
import 'hr_provider.dart';

class ParticipationChart extends StatelessWidget {
  const ParticipationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Mock Data points (height percentages) - Keep mock for chart visual as backend might not separate by week yet
    final data = [0.3, 0.45, 0.35, 0.6, 0.85, 0.7, 0.5, 0.4];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volunteer Participation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Last 30 Days',
                  items: const [
                    DropdownMenuItem(
                      value: 'Last 30 Days',
                      child: Text('Last 30 Days'),
                    ),
                  ],
                  onChanged: (v) {},
                  style: theme.textTheme.bodySmall,
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  isDense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.map((heightPct) {
                return Flexible(
                  child: FractionallySizedBox(
                    heightFactor: heightPct,
                    widthFactor: 0.6,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class HRScreen extends ConsumerWidget {
  const HRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(hrDashboardStatsProvider);
    final burnoutAsync = ref.watch(hrBurnoutRisksProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/hr/add-member'),
        label: const Text('Add Member'),
        icon: const Icon(Icons.person_add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Future.microtask(() => context.go('/dashboard'));
            }
          },
        ),
        title: const Text('HR Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(hrDashboardStatsProvider);
              ref.refresh(hrBurnoutRisksProvider);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lock Schedule
              // Volunteer List with Lock Toggle
              Text(
                'Manage Schedules',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              burnoutAsync.when(
                loading: () => const AppLoader(),
                error: (err, stack) => Text('Error: $err'),
                data: (volunteers) {
                  if (volunteers.isEmpty) {
                    return const AppEmptyState(
                      message: 'No volunteers found',
                      icon: Icons.people_outline,
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: volunteers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final volunteer = volunteers[index];
                      // Defaulting to false if lock status logic isn't in backend response yet
                      // ideally backend returns 'isScheduleLocked'
                      final isLocked = volunteer['isScheduleLocked'] ?? false;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Text((volunteer['name'] as String)[0]),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    volunteer['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    volunteer['role'] ?? 'Volunteer',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isLocked,
                              onChanged: (val) async {
                                // Optimistic UI update or refresh
                                // For now, we'll just call the API and refresh
                                try {
                                  await ref
                                      .read(hrRepositoryProvider)
                                      .toggleLock(volunteer['_id']);
                                  ref.refresh(
                                    hrBurnoutRisksProvider,
                                  ); // Refresh list
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          val
                                              ? 'Schedule Locked'
                                              : 'Schedule Unlocked',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Burnout Warning
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Burnout Warning',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'RISK',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: burnoutAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (risks) {
                    if (risks.isEmpty) {
                      return const Center(
                        child: Text('No burnout risks detected'),
                      );
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: risks.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final risk = risks[index];
                        return BurnoutWarningCard(
                          name: risk['name'] ?? 'Unknown',
                          role: risk['role'] ?? 'Volunteer',
                          imageUrl: 'https://via.placeholder.com/150',
                          currentHours: (risk['hoursWorked'] ?? 0).toDouble(),
                          maxHours: 40,
                          isCritical: (risk['riskLevel'] ?? 'LOW') == 'HIGH',
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Participation Chart
              const ParticipationChart(),

              const SizedBox(height: 24),

              // Camps per Manager (from stats)
              Text(
                'Stats Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              statsAsync.when(
                loading: () => const AppLoader(),
                error: (err, stack) => Text('Error loading stats: $err'),
                data: (stats) {
                  // Backend might return different structure, using placeholders if keys missing
                  final totalVolunteers = stats['totalVolunteers'] ?? 0;
                  final activeCamps = stats['activeCamps'] ?? 0;

                  return Column(
                    children: [
                      ManagerPerformanceCard(
                        name: 'Total Volunteers',
                        initials: 'TV',
                        status: '$totalVolunteers Active',
                        progress: 1.0,
                      ),
                      const SizedBox(height: 12),
                      ManagerPerformanceCard(
                        name: 'Active Camps',
                        initials: 'AC',
                        status: '$activeCamps Ongoing',
                        progress: 0.8,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
