import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _searchQuery = '';
  String _statusFilter = 'Active';
  String _cityFilter = 'All';
  String _groupFilter = 'All';
  String _urgencyFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _handleRequestAction(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> req,
  ) async {
    final currentStatus = req['status'] ?? 'Pending';
    final id = req['_id'];

    if (currentStatus == 'Pending') {
      _showAssignmentDialog(context, ref, id);
    } else if (currentStatus == 'Assigned') {
      await _updateStatus(context, ref, id, 'InProgress');
    } else if (currentStatus == 'InProgress') {
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
      ref.invalidate(helplineRequestsProvider);
      ref.invalidate(myRequestsProvider);
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
          height: 400,
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

              return ListView.separated(
                itemCount: volunteers.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final v = volunteers[i];
                  final isAvailable = v['availabilityStatus'] == true;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAvailable ? Colors.red : Colors.grey,
                      child: Text(
                        (v['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(v['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${v['city'] ?? 'Unknown location'} • ${v['phone'] ?? ''}',
                    ),
                    trailing: isAvailable
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
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
            const Text('Add completion notes and remark.'),
            const SizedBox(height: 16),
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(
                labelText: 'Remark',
                hintText: 'e.g., Blood units delivered successfully',
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
              if (remarkController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              _updateStatus(
                context,
                ref,
                id,
                'Completed',
                remark: remarkController.text.trim(),
              );
            },
            child: const Text('Submit'),
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

  Future<void> _handleCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    try {
      final Uri url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching call: $e');
    }
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
                          } catch (e) {
                            if (mounted) {
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
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const Icon(Icons.error, size: 20),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppTextField(
                label: 'Search Requests',
                controller: _searchController,
                hint: 'Search patient, hospital or ID...',
                prefixIcon: Icons.search,
              ),
            ),

            // Functional Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(
                    'Status: $_statusFilter',
                    () => _showFilterDialog('Status', [
                      'Active',
                      'Pending',
                      'Assigned',
                      'InProgress',
                      'Completed',
                      'All',
                    ], (v) => setState(() => _statusFilter = v)),
                    isActive: _statusFilter != 'All',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'City: $_cityFilter',
                    () => _showFilterDialog('City', [
                      'Delhi',
                      'Mumbai',
                      'Bangalore',
                      'Kolkata',
                      'All',
                    ], (v) => setState(() => _cityFilter = v)),
                    isActive: _cityFilter != 'All',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Group: $_groupFilter',
                    () => _showFilterDialog('Blood Group', [
                      'A+',
                      'A-',
                      'B+',
                      'B-',
                      'AB+',
                      'AB-',
                      'O+',
                      'O-',
                      'All',
                    ], (v) => setState(() => _groupFilter = v)),
                    isActive: _groupFilter != 'All',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Urgency: $_urgencyFilter',
                    () => _showFilterDialog('Urgency', [
                      'Critical',
                      'Urgent',
                      'Normal',
                      'All',
                    ], (v) => setState(() => _urgencyFilter = v)),
                    isActive: _urgencyFilter != 'All',
                  ),
                ],
              ),
            ),

            Expanded(
              child: ref
                  .watch(helplineRequestsProvider)
                  .when(
                    data: (requests) {
                      // Apply all filters
                      final filtered = requests.where((req) {
                        final matchesSearch =
                            _searchQuery.isEmpty ||
                            (req['patientName'] ?? '').toLowerCase().contains(
                              _searchQuery,
                            ) ||
                            (req['hospital'] ?? '').toLowerCase().contains(
                              _searchQuery,
                            );

                        final matchesStatus =
                            _statusFilter == 'All' ||
                            (_statusFilter == 'Active'
                                ? (req['status'] != 'Completed' &&
                                      req['status'] != 'Cancelled')
                                : req['status'] == _statusFilter);

                        final matchesCity =
                            _cityFilter == 'All' ||
                            (req['city'] ?? '').toLowerCase() ==
                                _cityFilter.toLowerCase();
                        final matchesGroup =
                            _groupFilter == 'All' ||
                            req['bloodGroup'] == _groupFilter;
                        final matchesUrgency =
                            _urgencyFilter == 'All' ||
                            req['urgencyLevel'] == _urgencyFilter;

                        return matchesSearch &&
                            matchesStatus &&
                            matchesCity &&
                            matchesGroup &&
                            matchesUrgency;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('No requests match your filters'),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final req = filtered[index];
                          final urgencyStr = req['urgencyLevel'] ?? 'Normal';
                          UrgencyLevel urgency = urgencyStr == 'Critical'
                              ? UrgencyLevel.critical
                              : (urgencyStr == 'Urgent'
                                    ? UrgencyLevel.high
                                    : UrgencyLevel.moderate);
                          final status = req['status'] ?? 'Pending';

                          String actionLabel = 'View Details';
                          if (status == 'Pending')
                            actionLabel = 'Assign Volunteer';
                          if (status == 'Assigned')
                            actionLabel = 'Start Progress';
                          if (status == 'InProgress') actionLabel = 'Complete';

                          return HelplineRequestCard(
                            patientName: req['patientName'] ?? 'Unknown',
                            hospital: req['hospital'] ?? 'Unknown Hospital',
                            timeAgo: _getTimeAgo(req['createdAt']),
                            bloodGroup: req['bloodGroup'] ?? '',
                            statusText: status,
                            urgency: urgency,
                            primaryActionLabel: actionLabel,
                            onCall: () => _handleCall(req['phone']),
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
        onPressed: () => context.push('/create-request'),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) {
          if (index == 0)
            context.go('/dashboard');
          else if (index == 1)
            context.go('/operations');
          else if (index == 3)
            context.go('/profile');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Operations',
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

  String _getTimeAgo(String? createdAt) {
    if (createdAt == null) return 'Just now';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return 'Just now';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildFilterChip(
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryColor
              : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? theme.primaryColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(),
          ...options.map(
            (opt) => ListTile(
              title: Text(opt),
              onTap: () {
                onSelect(opt);
                Navigator.pop(ctx);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
