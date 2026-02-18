import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_button.dart';
import '../../shared/components/app_card.dart';
import 'camp_provider.dart';

class CampListScreen extends ConsumerStatefulWidget {
  const CampListScreen({super.key});

  @override
  ConsumerState<CampListScreen> createState() => _CampListScreenState();
}

class _CampListScreenState extends ConsumerState<CampListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Camps'), centerTitle: true),
      body: ref
          .watch(campsProvider)
          .when(
            data: (camps) {
              if (camps.isEmpty) {
                return const Center(child: Text('No active camps found'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: camps.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final camp = camps[index];
                  final eventDate =
                      DateTime.tryParse(camp['eventDate'] ?? '') ??
                      DateTime.now();
                  final dateStr =
                      '${eventDate.day}/${eventDate.month}/${eventDate.year}';

                  return AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    camp['organizationName'] ?? 'Unknown Org',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        camp['location'] ?? 'Unknown Location',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  camp['workflowStatus'] ?? 'Scheduled',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStat(
                                context,
                                'Donations',
                                camp['donationCount']?.toString() ?? '0',
                                Icons.bloodtype,
                              ),
                              _buildStat(
                                context,
                                'Date',
                                dateStr,
                                Icons.calendar_today,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                context.push('/camp-details', extra: camp);
                              },
                              child: const Text('View Details'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCampDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateCampDialog(BuildContext context) {
    final orgController = TextEditingController();
    final pocController = TextEditingController();
    final locationController = TextEditingController();
    final bankController = TextEditingController();
    DateTime? selectedDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule Camp'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: orgController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: pocController,
                  decoration: const InputDecoration(labelText: 'POC Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: bankController,
                  decoration: const InputDecoration(
                    labelText: 'Blood Bank (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                InputDatePickerFormField(
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateSubmitted: (date) => selectedDate = date,
                  onDateSaved: (date) => selectedDate = date,
                  fieldLabelText: 'Event Date (dd/mm/yyyy)',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await ref.read(campRepositoryProvider).createCamp({
                    'organizationName': orgController.text.trim(),
                    'poc': pocController.text.trim(),
                    'location': locationController.text.trim(),
                    'bloodBank': bankController.text.trim(),
                    'eventDate': selectedDate!.toIso8601String(),
                  });
                  ref.refresh(campsProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camp scheduled successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to schedule camp: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
