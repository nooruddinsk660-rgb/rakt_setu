import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final VoidCallback? onActionTap;
  final String? actionText;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (action != null) action!,
          if (actionText != null && onActionTap != null)
            TextButton(onPressed: onActionTap, child: Text(actionText!)),
        ],
      ),
    );
  }
}
