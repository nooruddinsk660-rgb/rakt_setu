import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  void _handleContact(String donorId, String name) {
    ContactVerificationModal.show(
      context,
      donorName: name,
      onConfirm: () async {
        try {
          final contact = await ref
              .read(donorRepositoryProvider)
              .getDonorContact(donorId, 'Urgent Request');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Calling ${contact['name']} (${contact['phone']})...',
                ),
              ),
            );
            // In real app, launchUrl('tel:${contact['phone']}')
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to get contact: $e')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final donorsAsync = ref.watch(donorsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
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
                      phoneNumber: '******', // Hidden by default
                      isVerified:
                          true, // Assuming backend returns vetted donors
                      isAvailable: donor['availabilityStatus'] ?? true,
                      onContactTap: () => _handleContact(
                        donor['_id'],
                        donor['name'] ?? 'Donor',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
