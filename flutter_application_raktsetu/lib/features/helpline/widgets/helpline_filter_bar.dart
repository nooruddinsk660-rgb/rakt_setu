import 'package:flutter/material.dart';

class HelplineFilterBar extends StatelessWidget {
  const HelplineFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(context, 'Status: Active', isActive: true),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'City: Delhi NCR'),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Group: Any'),
          const SizedBox(width: 8),
          _buildFilterChip(context, 'Urgency'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label, {
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.primaryColor
            : isDark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? theme.primaryColor
              : isDark
              ? Colors.grey.shade800
              : Colors.grey.shade300,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isActive
                  ? Colors.white
                  : isDark
                  ? Colors.grey.shade300
                  : Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.expand_more,
            size: 16,
            color: isActive
                ? Colors.white
                : isDark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
        ],
      ),
    );
  }
}
