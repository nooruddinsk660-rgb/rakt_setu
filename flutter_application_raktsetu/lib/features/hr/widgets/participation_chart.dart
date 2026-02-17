import 'package:flutter/material.dart';

class ParticipationChart extends StatelessWidget {
  const ParticipationChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.map((heightPct) {
                return Flexible(
                  child: FractionallySizedBox(
                    heightFactor: heightPct,
                    widthFactor: 0.6,
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
