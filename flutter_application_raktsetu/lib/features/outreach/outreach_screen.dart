import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_loader.dart';
import '../../shared/components/app_empty_state.dart';
import 'widgets/kanban_tab.dart';
import 'widgets/outreach_card.dart';
import 'outreach_provider.dart';

class OutreachScreen extends ConsumerStatefulWidget {
  const OutreachScreen({super.key});

  @override
  ConsumerState<OutreachScreen> createState() => _OutreachScreenState();
}

class _OutreachScreenState extends ConsumerState<OutreachScreen> {
  int _selectedTabIndex = 0;

  // Tabs matching backend status enum or logic
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Not Contacted', 'status': 'NotContacted'},
    {'title': 'Pending', 'status': 'Pending'},
    {'title': 'Successful', 'status': 'Successful'},
    {'title': 'Cancelled', 'status': 'Cancelled'},
  ];

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(outreachLeadsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Outreach Board',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        ref.refresh(outreachLeadsProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final status = tab['status'];

                  // Calculate count from provider data if available
                  int count = 0;
                  leadsAsync.whenData((leads) {
                    count = leads.where((l) => l['status'] == status).length;
                  });

                  return KanbanTab(
                    title: tab['title'],
                    count: count,
                    isSelected: _selectedTabIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: leadsAsync.when(
                loading: () => const AppLoader(),
                error: (err, stack) => AppEmptyState(
                  message: 'Error loading leads',
                  subMessage: err.toString(),
                  icon: Icons.error_outline,
                ),
                data: (leads) {
                  final selectedStatus = _tabs[_selectedTabIndex]['status'];
                  final filteredLeads = leads
                      .where((lead) => lead['status'] == selectedStatus)
                      .toList();

                  if (filteredLeads.isEmpty) {
                    return const AppEmptyState(
                      message: 'No leads in this stage',
                      icon: Icons.inbox,
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Column Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tabs[_selectedTabIndex]['title']
                                .toString()
                                .toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).hintColor,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ...filteredLeads.map((lead) {
                        final poc = lead['pocDetails'] ?? {};
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: OutreachCard(
                            title: lead['organizationName'] ?? 'Unknown Org',
                            location: lead['location'] ?? 'Unknown Location',
                            type: lead['type'] ?? 'General',
                            // Mock image for now
                            imageUrl: 'https://via.placeholder.com/150',
                            stripColor: _getStatusColor(lead['status']),
                            onCall: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Calling ${poc['name'] ?? 'POC'}...',
                                  ),
                                ),
                              );
                            },
                            onEmail: () {},
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateLeadDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/donors');
          if (index == 2) context.go('/helpline');
          if (index == 3) context.go('/profile');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Donors',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showCreateLeadDialog(BuildContext context) {
    final orgController = TextEditingController();
    final pocNameController = TextEditingController();
    final pocPhoneController = TextEditingController();
    final purposeController = TextEditingController();
    final locationController = TextEditingController();
    String selectedType = 'Corporate'; // Default
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Outreach Lead'),
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
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Corporate', 'College', 'Residential', 'Other']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => selectedType = v!,
                ),
                const SizedBox(height: 16),
                const Text(
                  'POC Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: pocNameController,
                  decoration: const InputDecoration(labelText: 'POC Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: pocPhoneController,
                  decoration: const InputDecoration(labelText: 'POC Phone'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: purposeController,
                  decoration: const InputDecoration(labelText: 'Purpose'),
                  maxLines: 2,
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
                  await ref.read(outreachRepositoryProvider).createLead({
                    'organizationName': orgController.text.trim(),
                    'location': locationController.text.trim(),
                    'type': selectedType,
                    'pocDetails': {
                      'name': pocNameController.text.trim(),
                      'phone': pocPhoneController.text.trim(),
                    },
                    'purpose': purposeController.text.trim(),
                  });
                  ref.refresh(outreachLeadsProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lead created successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create lead: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'NotContacted':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Successful':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
