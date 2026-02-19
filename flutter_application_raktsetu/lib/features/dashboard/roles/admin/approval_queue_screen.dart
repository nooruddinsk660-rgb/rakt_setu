import 'package:flutter/material.dart';
import '../../../../shared/components/app_card.dart';
import '../../../../shared/components/app_button.dart';

class ApprovalQueueScreen extends StatefulWidget {
  const ApprovalQueueScreen({super.key});

  @override
  State<ApprovalQueueScreen> createState() => _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends State<ApprovalQueueScreen> {
  // Mock Data
  final List<Map<String, dynamic>> _pendingHospitals = [
    {
      'id': '1',
      'name': 'City General Hospital',
      'license': 'LIC-2024-001',
      'location': 'Downtown, 2.5km away',
    },
    {
      'id': '2',
      'name': 'Community Health Center',
      'license': 'LIC-2024-005',
      'location': 'Westside, 5.0km away',
    },
  ];

  void _handleAction(String id, bool approved) {
    setState(() {
      _pendingHospitals.removeWhere((h) => h['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved ? 'Hospital Approved' : 'Hospital Rejected'),
        backgroundColor: approved ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hospital Approvals')),
      body: _pendingHospitals.isEmpty
          ? const Center(child: Text('No pending approvals'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingHospitals.length,
              itemBuilder: (context, index) {
                final hospital = _pendingHospitals[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hospital['name'],
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'License: ${hospital['license']}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  hospital['location'],
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _handleAction(hospital['id'], false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Approve',
                              onPressed: () =>
                                  _handleAction(hospital['id'], true),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
