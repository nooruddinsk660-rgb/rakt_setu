import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_text_field.dart';
import 'widgets/helpline_filter_bar.dart';
import 'widgets/helpline_request_card.dart';
import 'helpline_provider.dart';

class HelplineScreen extends ConsumerStatefulWidget {
  const HelplineScreen({super.key});

  @override
  ConsumerState<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends ConsumerState<HelplineScreen> {
  final _searchController = TextEditingController();

  Future<void> _handleRequestAction(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> req,
  ) async {
    final currentStatus = req['status'] ?? 'Pending';
    final id = req['_id'];

    if (currentStatus == 'Pending') {
      // Assign to self or trigger assignment logic
      // For now, simpler flow: Auto-assign to self (if backend allows) or just move to Assigned
      // Backend createRequest does smart assignment. If Pending, it means no one found?
      // Let's assume this button means "I accept this request"
      // But we need to know if the backend supports "pick up".
      // Backend updateStatus allows moving to Assigned? No, usually create -> assigned.
      // If Pending, maybe we can move to Assigned manually?
      // Let's try updating to 'Assigned'.
      await _updateStatus(context, ref, id, 'Assigned');
    } else if (currentStatus == 'Assigned') {
      // Move to InProgress
      await _updateStatus(context, ref, id, 'InProgress');
    } else if (currentStatus == 'InProgress') {
      // Move to Completed - Requires Remark
      _showCompletionDialog(context, ref, id);
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status, {
    String? remark,
  }) async {
    try {
      await ref
          .read(helplineRepositoryProvider)
          .updateStatus(id, status, callRemark: remark);
      // Refresh list
      ref.invalidate(helplineRequestsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  void _showCompletionDialog(BuildContext context, WidgetRef ref, String id) {
    final remarkController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please add a remark to close this request.'),
            const SizedBox(height: 16),
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: 'Remark',
                hintText: 'e.g., Donor found, transfusion successful',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (remarkController.text.trim().isEmpty) {
                return; // Validation handled by UI state or just ignore
              }
              Navigator.pop(ctx);
              _updateStatus(
                context,
                ref,
                id,
                'Completed',
                remark: remarkController.text.trim(),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Live Requests',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'BloodConnect Command Center',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.refresh),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Search Requests',
                    controller: _searchController,
                    hint: 'Search patient, hospital or ID...',
                    prefixIcon: Icons.search,
                  ),
                ],
              ),
            ),

            // Filters
            const HelplineFilterBar(),

            // List
            Expanded(
              child: ref
                  .watch(helplineRequestsProvider)
                  .when(
                    data: (requests) {
                      if (requests.isEmpty) {
                        return const Center(child: Text('No active requests'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: requests.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          // Data Mapping
                          final urgencyStr = req['urgencyLevel'] ?? 'Normal';
                          UrgencyLevel urgency;
                          if (urgencyStr == 'Critical') {
                            urgency = UrgencyLevel.critical;
                          } else if (urgencyStr == 'Urgent') {
                            urgency = UrgencyLevel.high;
                          } else {
                            urgency = UrgencyLevel.moderate;
                          }

                          final status = req['status'] ?? 'Pending';
                          String actionLabel = 'View Details';
                          if (status == 'Pending') actionLabel = 'Assign Donor';
                          if (status == 'Assigned') actionLabel = 'Verify';

                          // Time Ago Logic
                          String timeAgo = 'Just now';
                          final createdAt = req['createdAt'] as String?;
                          if (createdAt != null) {
                            final date = DateTime.tryParse(createdAt);
                            if (date != null) {
                              final diff = DateTime.now().difference(date);
                              if (diff.inMinutes < 60) {
                                timeAgo = '${diff.inMinutes}m ago';
                              } else if (diff.inHours < 24) {
                                timeAgo = '${diff.inHours}h ago';
                              } else {
                                timeAgo = '${diff.inDays}d ago';
                              }
                            }
                          }

                          return HelplineRequestCard(
                            patientName: req['patientName'] ?? 'Unknown',
                            hospital: req['hospital'] ?? 'Unknown Hospital',
                            timeAgo: timeAgo,
                            bloodGroup: req['bloodGroup'] ?? '',
                            statusText: status,
                            urgency: urgency,
                            primaryActionLabel: actionLabel,
                            onCall: () {
                              // TODO: Implement call launcher
                            },
                            onPrimaryAction: () =>
                                _handleRequestAction(context, ref, req),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2, // Requests
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/dashboard');
          } else if (index == 1) {
            context.go('/donors');
          } else if (index == 2) {
            // Already on Requests
          } else if (index == 3) {
            context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Volunteers',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
