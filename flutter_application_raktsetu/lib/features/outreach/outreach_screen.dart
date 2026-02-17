import 'package:flutter/material.dart';
import '../../shared/components/app_text_field.dart';
import 'widgets/kanban_tab.dart';
import 'widgets/outreach_card.dart';

class OutreachScreen extends StatefulWidget {
  const OutreachScreen({super.key});

  @override
  State<OutreachScreen> createState() => _OutreachScreenState();
}

class _OutreachScreenState extends State<OutreachScreen> {
  int _selectedTabIndex = 0;
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Not Contacted', 'count': 2, 'status': 'not_contacted'},
    {'title': 'Pending', 'count': 1, 'status': 'pending'},
    {'title': 'Successful', 'count': 5, 'status': 'successful'},
    {'title': 'Cancelled', 'count': 1, 'status': 'cancelled'},
  ];

  final List<Map<String, dynamic>> _leads = [
    {
      'title': 'Apex University',
      'location': 'New Delhi',
      'type': 'College',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuATaMsudhsYmlboJzjY5pwUFPJqD2ltaq3rn32PlEYa0J-maprf039xZGHdNsao_ZLEk1l2N8b6WjcgCn3AKrcxsg0ZpVmYp6hSoEBc2EnRga3SBlk-BjH5-gNQuNVXKMp_HZoDqfBORaH3AsyXxIODO1z4s8VlOt8dwfwjGsvMPccwfdZapaiVxW_2K7qQeB_DGTpGInnjbnEpAbZD4qwmCe_mKn6O6DjKA9tV3JIJhAVaNAK4kj__-LnXNyfQ5HBw2xyTSiCowLjY',
      'status': 'not_contacted',
      'stripColor': Colors.blue,
    },
    {
      'title': 'TechSolutions Park',
      'location': 'Gurgaon, Cyber City',
      'type': 'Corporate',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDYNDzfOPlEnmKO8YiqEXPlaJspwReiujRoBNbExwXAyl0QAbYQKs5Kzw6EqoIMtHYU1Wico4H21MwvT9wHmTz3gw2PvvUqiaO6PZHNplHmagEFxbVVcKyJojKdHJZzHNfSCibYR6wjrXg9EOrYHZ08ScDVFDXxnSN56ICvuBFpKNzVyWiKmzq6iwlgzMKbBG71HtbR3DUpDg0ObVlN8oU3UR5zkZ13_zWHZ5qSZku39HsBYziNQ1THIX7NNX6JtPBP0BuNRBZB_9zM',
      'status': 'not_contacted',
      'stripColor': Colors.purple,
    },
    {
      'title': 'City Mall',
      'location': 'Saket',
      'type': 'Corporate',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAhgJREtWJe7hIMFt1idLkzZIxXyRNAyIg3flIyhDzlGze62jXlsevo7PHyDY7QLSDR466mpXyV1OysIhcQBfboIm5UnczTnEzJgR0p9_65SgT5kT7MHwXnrfI1u9V-AythBW81Jm8pv3ZN2U3AkUW4953HGyExWizPmGDSX5Dc3V06C3kXzE3_uqrZQqY2c2pBQgBJQGdQbo6EEzB8vehHAOw6lisHJXkpMtVSUUOllAyvDpFyuKuubVMaJdDsz33ARciOm09sJQsE',
      'status': 'pending',
      'stripColor': Colors.orange,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStatus = _tabs[_selectedTabIndex]['status'];
    final filteredLeads = _leads
        .where((lead) => lead['status'] == selectedStatus)
        .toList();

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
                      icon: const Icon(Icons.search),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {},
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
                  return KanbanTab(
                    title: tab['title'],
                    count: tab['count'],
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
              child: ListView(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.sort, size: 16),
                        label: const Text(
                          'SORT',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(60, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...filteredLeads.map(
                    (lead) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: OutreachCard(
                        title: lead['title'],
                        location: lead['location'],
                        type: lead['type'],
                        imageUrl: lead['imageUrl'],
                        stripColor:
                            lead['stripColor'] ??
                            Theme.of(context).primaryColor,
                        onCall: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${lead['title']}...'),
                            ),
                          );
                        },
                        onEmail: () {},
                      ),
                    ),
                  ),

                  // Add New Lead Button
                  InkWell(
                    onTap: () {
                      // Navigate to add lead
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                          style: BorderStyle
                              .solid, // Dashed not natively supported easily without pkg, solid fine for now
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add New Lead',
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    );
  }
}
