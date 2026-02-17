import 'package:flutter/material.dart';

class WorkflowStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final ScrollController? scrollController;

  const WorkflowStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final isLast = index == steps.length - 1;

          Color circleColor;
          Color textColor;

          if (isCompleted) {
            circleColor = primaryColor;
            textColor = primaryColor;
          } else if (isCurrent) {
            circleColor = primaryColor;
            textColor = primaryColor;
          } else {
            circleColor = Colors.grey.shade300;
            textColor = Colors.grey;
          }

          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? primaryColor : Colors.transparent,
                      border: Border.all(color: circleColor, width: 2),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? primaryColor : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  width: 40,
                  height: 2,
                  color: isCompleted ? primaryColor : Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ).copyWith(bottom: 20),
                ),
            ],
          );
        }),
      ),
    );
  }
}
