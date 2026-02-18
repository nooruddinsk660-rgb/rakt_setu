import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_text_field.dart';
import 'widgets/helpline_filter_bar.dart';
import 'widgets/helpline_request_card.dart';
import 'helpline_provider.dart';
import '../volunteer/volunteer_provider.dart';
import '../hr/hr_provider.dart';

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
      _showAssignmentDialog(context, ref, id);
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
    String? assignedVolunteerId,
  }) async {
    try {
      await ref
          .read(helplineRepositoryProvider)
          .updateStatus(
            id,
            status,
            callRemark: remark,
            assignedVolunteerId: assignedVolunteerId,
          );
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

  void _showAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
    String requestId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Volunteer'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FutureBuilder<List<dynamic>>(
            future: ref.read(hrRepositoryProvider).getVolunteers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final volunteers = snapshot.data ?? [];
              if (volunteers.isEmpty) {
                return const Center(child: Text('No active volunteers found'));
              }

              // Filter out those not available if needed, or show all
              return ListView.separated(
                itemCount: volunteers.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final v = volunteers[i];
                  return ListTile(
                    leading: CircleAvatar(child: Text((v['name'] ?? 'U')[0])),
                    title: Text(v['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${v['city'] ?? 'Unknown location'} • ${v['phone'] ?? ''}',
                    ),
                    trailing: v['availabilityStatus'] == true
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          )
                        : const Icon(
                            Icons.cancel,
                            color: Colors.grey,
                            size: 16,
                          ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _updateStatus(
                        context,
                        ref,
                        requestId,
                        'Assigned',
                        assignedVolunteerId: v['_id'],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Future.microtask(() => context.go('/dashboard'));
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Requests',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'BloodConnect Command Center',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final profileAsync = ref.watch(volunteerProfileProvider);
              return profileAsync.when(
                data: (profile) {
                  final isOnline = profile['availabilityStatus'] ?? false;
                  return Row(
                    children: [
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                      Switch(
                        value: isOnline,
                        activeColor: Colors.green,
                        onChanged: (val) async {
                          try {
                            await ref
                                .read(volunteerRepositoryProvider)
                                .updateStatus(availabilityStatus: val);
                            ref.invalidate(volunteerProfileProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    val
                                        ? 'You are now Online'
                                        : 'You are now Offline',
                                  ),
                                  backgroundColor: val
                                      ? Colors.green
                                      : Colors.grey,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (err, stack) => const Icon(Icons.error, size: 20),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar (Moved out of header)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppTextField(
                label: 'Search Requests',
                controller: _searchController,
                hint: 'Search patient, hospital or ID...',
                prefixIcon: Icons.search,
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
            Future.microtask(() => context.go('/dashboard'));
          } else if (index == 1) {
            Future.microtask(() => context.go('/donors'));
          } else if (index == 2) {
            // Already on Requests
          } else if (index == 3) {
            Future.microtask(() => context.go('/profile'));
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
