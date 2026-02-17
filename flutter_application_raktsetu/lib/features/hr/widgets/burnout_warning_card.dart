import 'package:flutter/material.dart';

class BurnoutWarningCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final int currentHours;
  final int maxHours;
  final bool isCritical;

  const BurnoutWarningCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.currentHours,
    required this.maxHours,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = currentHours / maxHours;
    final percentage = (progress * 100).toInt();
    final excess = ((currentHours - maxHours) / maxHours * 100).toInt();

    Color riskColor = isCritical ? theme.primaryColor : Colors.amber;
    Color iconColor = isCritical ? theme.primaryColor : Colors.amber;

    // Custom container decoration based on risk
    BoxDecoration decoration = BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isCritical
            ? theme.primaryColor
            : isDark
            ? Colors.grey.shade800
            : Colors.grey.shade200,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (isCritical) {
      decoration = decoration.copyWith(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade800,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade800,
          ),
          right: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade800,
          ),
          left: BorderSide(color: theme.primaryColor, width: 4),
        ),
      );
    } else {
      decoration = decoration.copyWith(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          right: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          left: const BorderSide(color: Colors.amber, width: 4),
        ),
      );
    }

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                isCritical ? Icons.warning : Icons.error,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hours this week',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                '${currentHours}h / ${maxHours}h',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(riskColor),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isCritical
                ? 'High Risk: Exceeds limit by $excess%'
                : 'Warning: Approaching burnout',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCritical ? theme.primaryColor : Colors.amber.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
