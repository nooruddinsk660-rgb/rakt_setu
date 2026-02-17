import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_text_field.dart';
import 'widgets/helpline_filter_bar.dart';
import 'widgets/helpline_request_card.dart';

class HelplineScreen extends StatefulWidget {
  const HelplineScreen({super.key});

  @override
  State<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends State<HelplineScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _requests = [
    {
      'patientName': 'Rohan Gupta',
      'hospital': 'AIIMS Trauma Center, New Delhi',
      'timeAgo': '20m ago',
      'bloodGroup': 'AB+',
      'statusText': '2 Donors arranged',
      'urgency': UrgencyLevel.critical,
      'primaryActionLabel': 'Assign Donor',
    },
    {
      'patientName': 'Priya Sharma',
      'hospital': 'Max Hospital, Saket',
      'timeAgo': '1h ago',
      'bloodGroup': 'O-',
      'statusText': 'Verifying requirement',
      'urgency': UrgencyLevel.moderate,
      'primaryActionLabel': 'View Details',
    },
    {
      'patientName': 'Amit Verma',
      'hospital': 'Fortis Escorts, Okhla',
      'timeAgo': '2h ago',
      'bloodGroup': 'B+',
      'statusText': 'Needs verification',
      'urgency': UrgencyLevel.high,
      'primaryActionLabel': 'Verify',
    },
    {
      'patientName': 'Suresh Kumar',
      'hospital': 'Apollo Hospital, Sarita Vihar',
      'timeAgo': '5h ago',
      'bloodGroup': 'A+',
      'statusText': 'Donation complete',
      'urgency': UrgencyLevel.fulfilled,
      'primaryActionLabel': 'Details',
    },
  ];

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
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _requests.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final req = _requests[index];
                  return HelplineRequestCard(
                    patientName: req['patientName'],
                    hospital: req['hospital'],
                    timeAgo: req['timeAgo'],
                    bloodGroup: req['bloodGroup'],
                    statusText: req['statusText'],
                    urgency: req['urgency'],
                    primaryActionLabel: req['primaryActionLabel'],
                    onCall: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling...')),
                      );
                    },
                    onPrimaryAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Action: ${req['primaryActionLabel']}'),
                        ),
                      );
                    },
                  );
                },
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
