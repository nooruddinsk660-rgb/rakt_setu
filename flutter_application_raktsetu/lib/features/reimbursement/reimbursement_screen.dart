import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'reimbursement_provider.dart';
import 'reimbursement_repository.dart';
import '../../shared/components/app_button.dart';
import '../../shared/components/app_text_field.dart';
import '../camp/camp_provider.dart';

class ReimbursementScreen extends ConsumerStatefulWidget {
  const ReimbursementScreen({super.key});

  @override
  ConsumerState<ReimbursementScreen> createState() =>
      _ReimbursementScreenState();
}

class _ReimbursementScreenState extends ConsumerState<ReimbursementScreen> {
  void _showCreateDialog() {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final receiptController = TextEditingController(
      text: 'https://cdn-icons-png.flaticon.com/512/2933/2933116.png',
    ); // Mock receipt
    String? selectedEventId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Reimbursement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final campsAsync = ref.watch(campsProvider);
                  return campsAsync.when(
                    data: (camps) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Camp/Event',
                      ),
                      items: camps.map<DropdownMenuItem<String>>((c) {
                        return DropdownMenuItem(
                          value: c['_id'],
                          child: Text(c['organizationName'] ?? 'Unnamed Event'),
                        );
                      }).toList(),
                      onChanged: (val) => selectedEventId = val,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => Text('Error loading camps: $e'),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Amount (₹)',
                controller: amountController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: descController,
                hint: 'Travel, Food, etc.',
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Receipt URL (Proof)',
                controller: receiptController,
                prefixIcon: Icons.link,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedEventId == null || amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill required fields')),
                );
                return;
              }
              try {
                await ref
                    .read(reimbursementRepositoryProvider)
                    .createReimbursement(
                      eventId: selectedEventId!,
                      amount: double.parse(amountController.text),
                      receiptUrl: receiptController.text,
                      description: descController.text,
                    );
                ref.invalidate(myReimbursementsProvider);
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reimbursementsAsync = ref.watch(myReimbursementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Reimbursements')),
      body: reimbursementsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No reimbursement requests found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final r = list[i];
              final status = r['status'] ?? 'Pending';
              Color statusColor = Colors.orange;
              if (status == 'Approved') statusColor = Colors.green;
              if (status == 'Rejected') statusColor = Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    r['eventId']?['organizationName'] ?? 'Unknown Event',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Amount: ₹${r['amount']}'),
                      Text(
                        'Description: ${r['description'] ?? 'No description'}',
                      ),
                      Text(
                        'Date: ${DateTime.parse(r['createdAt']).toLocal().toString().split('.')[0]}',
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text('New Request'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
