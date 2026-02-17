import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final bool isOutlined;

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;
    final onBadgeColor = textColor ?? Colors.white;

    if (isOutlined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: badgeColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: onBadgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
