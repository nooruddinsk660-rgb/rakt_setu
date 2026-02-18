import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../outreach_provider.dart';

class OutreachFilterBar extends ConsumerWidget {
  const OutreachFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(outreachFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            ref,
            'Type',
            filters['type'],
            ['Corporate', 'College', 'Residential', 'Other'],
            (val) => ref
                .read(outreachFilterProvider.notifier)
                .update((state) => {...state, 'type': val}),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            ref,
            'Location',
            filters['location'],
            null, // Free text input for location
            (val) => ref
                .read(outreachFilterProvider.notifier)
                .update((state) => {...state, 'location': val}),
            isInput: true,
          ),
          const SizedBox(width: 8),
          if (filters.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(outreachFilterProvider.notifier).state = {};
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String? currentValue,
    List<String>? options,
    Function(String?) onSelected, {
    bool isInput = false,
  }) {
    final theme = Theme.of(context);
    final isActive = currentValue != null && currentValue.isNotEmpty;
    final displayLabel = isActive ? '$label: $currentValue' : label;

    return ActionChip(
      label: Text(displayLabel),
      avatar: isActive ? const Icon(Icons.check, size: 16) : null,
      backgroundColor: isActive ? theme.primaryColor.withOpacity(0.1) : null,
      side: isActive ? BorderSide(color: theme.primaryColor) : null,
      onPressed: () {
        if (isInput) {
          _showInputDialog(context, label, currentValue, onSelected);
        } else if (options != null) {
          _showOptionsDialog(context, label, options, onSelected);
        }
      },
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    String title,
    List<String> options,
    Function(String?) onSelected,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select $title'),
        children: [
          SimpleDialogOption(
            child: const Text('Any'),
            onPressed: () {
              onSelected(null);
              Navigator.pop(ctx);
            },
          ),
          ...options.map(
            (opt) => SimpleDialogOption(
              child: Text(opt),
              onPressed: () {
                onSelected(opt);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(
    BuildContext context,
    String title,
    String? currentValue,
    Function(String?) onSelected,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Filter by $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onSelected(null);
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              onSelected(
                controller.text.trim().isEmpty ? null : controller.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
