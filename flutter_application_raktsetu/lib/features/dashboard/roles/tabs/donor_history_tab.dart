import 'package:flutter/material.dart';
import '../../../../shared/components/app_card.dart';

class DonorHistoryTab extends StatelessWidget {
  const DonorHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return AppCard(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            title: Text('Donation #${100 - index}'),
            subtitle: Text('City Hospital • ${index + 1} month ago'),
            trailing: Text(
              'Verified',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
