import 'package:flutter/material.dart';
import 'widgets/burnout_warning_card.dart';
import 'widgets/manager_performance_card.dart';

class ParticipationChart extends StatelessWidget {
  const ParticipationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Mock Data points (height percentages)
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
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Align bars to bottom
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.map((heightPct) {
                return Flexible(
                  child: FractionallySizedBox(
                    heightFactor: heightPct,
                    widthFactor: 0.6,
                    alignment: Alignment.bottomCenter, // crucial
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        boxShadow: heightPct > 0.8
                            ? [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, -4),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week 1',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                'Week 2',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                'Week 3',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                'Week 4',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HRScreen extends StatelessWidget {
  const HRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lock Schedule
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lock Schedule',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Freeze assignments for next week',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(value: false, onChanged: (v) {}),
                  ],
                ),
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
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CRITICAL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(onPressed: () {}, child: const Text('View All')),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240, // Height for Burnout Cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: const [
                    BurnoutWarningCard(
                      name: 'Rahul S.',
                      role: 'Senior Volunteer',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuD-zqRQlWSDRtXzd0qUvIN4q4kAnXhF4FJpuXypc_KvUSC2J0uO-hfwtX__MYLMGoEevTzy_Zlv2luJrktERAgorzYJhKHJsw2QBwD1ALh2dRb-IfxpGPpzzv-Ra02aWowRGUHRNdOnvS9bXxbJ1_2hJ4tVu0ZLKaEiZP_z7TlL32jlgUSXUPWk1ciMHSo7a-f4ZQA9c5GPXrTJ6Tb7kLolTD00QTMMXTCk93C8feGO1aFR0q8osF3TYc0VXln55PhP5Dj12VcYiwkk',
                      currentHours: 55,
                      maxHours: 40,
                      isCritical: true,
                    ),
                    SizedBox(width: 16),
                    BurnoutWarningCard(
                      name: 'Priya M.',
                      role: 'Codeinator',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAEt39EznI8X2WSu-cUy7-Jzgc1NudJcx_5JXPPuHPTnzGy_Xl0YfXsZ9q4xIDbrb9wVVJfqVPGQxmhc91oS437IHbFLtdYhSI3pDFxuV8P54qMXJd9iLTrR9Tgrf__C0iU0Wm8I5pXxGHxkewX6FQ_cGQkNuDqQlBoVn5drxVv_UmsJ5ayIavUl0-LHSAiqNbJ9B-b1r7d3XQ_UL3SFdg_Wn5W8VAFCsL7LUceGHoLtbPa1hZGMEco8hwM5SuFuXoCJae6tHPeYzvY',
                      currentHours: 42,
                      maxHours: 40,
                      isCritical: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Participation Chart
              const ParticipationChart(),

              const SizedBox(height: 24),

              // Camps per Manager
              Text(
                'Camps per Manager',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Column(
                children: [
                  ManagerPerformanceCard(
                    name: 'Amit K.',
                    initials: 'AK',
                    status: '5 Active Camps',
                    progress: 0.85,
                  ),
                  SizedBox(height: 12),
                  ManagerPerformanceCard(
                    name: 'Sneha R.',
                    initials: 'SR',
                    status: '3 Active Camps',
                    progress: 0.5,
                  ),
                  SizedBox(height: 12),
                  ManagerPerformanceCard(
                    name: 'John D.',
                    initials: 'JD',
                    status: '2 Active Camps',
                    progress: 0.35,
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
