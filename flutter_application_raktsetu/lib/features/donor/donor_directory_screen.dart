import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/components/app_loader.dart';
import '../../shared/components/app_empty_state.dart';
import 'widgets/donor_search_filter.dart';
import 'widgets/donor_card.dart';
import 'widgets/contact_verification_modal.dart';
import 'donor_provider.dart';

class DonorDirectoryScreen extends ConsumerStatefulWidget {
  const DonorDirectoryScreen({super.key});

  @override
  ConsumerState<DonorDirectoryScreen> createState() =>
      _DonorDirectoryScreenState();
}

class _DonorDirectoryScreenState extends ConsumerState<DonorDirectoryScreen> {
  void _handleSearch(String bloodGroup, String location) {
    ref.read(donorFilterProvider.notifier).state = {
      if (bloodGroup.isNotEmpty) 'bloodGroup': bloodGroup,
      if (location.isNotEmpty) 'city': location,
    };
  }

  void _handleContact(String name, String phone) {
    ContactVerificationModal.show(
      context,
      donorName: name,
      onConfirm: () {
        // In real app, decrypt phone and launch dialer
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Calling $name  ($phone)...')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final donorsAsync = ref.watch(donorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donor Search',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'BloodConnect Secure Directory',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(donorsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DonorSearchFilter(onSearch: _handleSearch),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Donors',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                donorsAsync.maybeWhen(
                  data: (donors) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${donors.length} Found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: donorsAsync.when(
              loading: () => const AppLoader(),
              error: (err, stack) => AppEmptyState(
                message: 'Error loading donors',
                subMessage: err.toString(),
                icon: Icons.error_outline,
              ),
              data: (donors) {
                if (donors.isEmpty) {
                  return const AppEmptyState(
                    message: 'No donors found',
                    icon: Icons.search_off,
                    subMessage: 'Try adjusting your filters',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: donors.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    final eventDate =
                        DateTime.tryParse(donor['lastDonationDate'] ?? '') ??
                        DateTime.now();
                    final lastDonated =
                        '${eventDate.day}/${eventDate.month}/${eventDate.year}';

                    return DonorCard(
                      name: donor['name'] ?? 'Unknown',
                      location: donor['city'] ?? 'Unknown City',
                      distance:
                          'Unknown', // Backend doesn't support distance yet
                      bloodGroup: donor['bloodGroup'] ?? '',
                      lastDonated: lastDonated,
                      phoneNumber: donor['phoneEncrypted'] ?? '******',
                      isVerified:
                          true, // Assuming backend returns vetted donors
                      isAvailable: donor['availabilityStatus'] ?? true,
                      onContactTap: () => _handleContact(
                        donor['name'] ?? 'Donor',
                        donor['phoneEncrypted'] ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDonorDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDonorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final cityController = TextEditingController();
    String? selectedBloodGroup;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Donor'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(labelText: 'Blood Group'),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => selectedBloodGroup = v,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
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
                Navigator.pop(ctx);
                try {
                  await ref.read(donorRepositoryProvider).addDonor({
                    'name': nameController.text.trim(),
                    'bloodGroup': selectedBloodGroup,
                    'phone': phoneController.text.trim(),
                    'city': cityController.text.trim(),
                    // lastDonationDate optional
                  });
                  ref.refresh(donorsProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Donor added successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add donor: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
