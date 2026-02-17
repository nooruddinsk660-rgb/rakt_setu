import 'package:flutter/material.dart';

class QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: label == 'New Camp' ? theme.primaryColor : theme.cardColor,
              shape: BoxShape.circle,
              border: label == 'New Camp'
                  ? null
                  : Border.all(color: theme.dividerColor.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: label == 'New Camp'
                      ? theme.primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: label == 'New Camp'
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.grey.shade700),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
