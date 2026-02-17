import 'package:flutter/material.dart';

enum StepStatus { completed, active, pending }

class CampTimelineStep extends StatelessWidget {
  final String title;
  final String? date;
  final String? subtitle;
  final StepStatus status;
  final bool isLast;
  final List<Widget>? actions;

  const CampTimelineStep({
    super.key,
    required this.title,
    this.date,
    this.subtitle,
    required this.status,
    this.isLast = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color indicatorColor;
    Color contentColor;
    Widget indicatorIcon;

    switch (status) {
      case StepStatus.completed:
        indicatorColor = Colors.green.withOpacity(0.2);
        contentColor = theme.textTheme.bodyMedium!.color!;
        indicatorIcon = const Icon(Icons.check, color: Colors.green, size: 16);
        break;
      case StepStatus.active:
        indicatorColor = theme.primaryColor;
        contentColor = theme.primaryColor;
        indicatorIcon = const Icon(
          Icons.bloodtype,
          color: Colors.white,
          size: 16,
        );
        break;
      case StepStatus.pending:
        indicatorColor = theme.disabledColor.withOpacity(0.2);
        contentColor = theme.disabledColor;
        indicatorIcon = Icon(
          Icons.circle,
          color: theme.disabledColor,
          size: 12,
        );
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: status == StepStatus.active
                        ? theme.primaryColor
                        : indicatorColor,
                    shape: BoxShape.circle,
                    border: status == StepStatus.active
                        ? Border.all(
                            color: theme.primaryColor.withOpacity(0.3),
                            width: 4,
                          )
                        : null,
                    boxShadow: status == StepStatus.active
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: indicatorIcon),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: status == StepStatus.active
                              ? theme.primaryColor
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      if (date != null)
                        Text(
                          date!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      if (status == StepStatus.active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (actions != null && actions!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(children: actions!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
