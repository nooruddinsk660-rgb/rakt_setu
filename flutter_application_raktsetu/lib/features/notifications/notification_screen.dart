import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_filter_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Helpline',
    'Escalations',
    'Reimbursements',
  ];

  // Mock Data
  final List<Map<String, dynamic>> _allNotifications = [
    {
      'title': 'Urgent: Blood request #4029 unfulfilled',
      'description':
          'Sector 4 - B+ Positive needed immediately for trauma case at City Hospital.',
      'timeAgo': '2m ago',
      'type': NotificationType.escalation,
      'isUnread': true,
      'tags': ['Escalation', 'B+ Positive'],
      'category': 'Escalations',
      'date': 'Today',
    },
    {
      'title': 'Incoming Assignment: Caller #8821',
      'description':
          'New caller assigned to your queue. Requesting information about platelet donation.',
      'timeAgo': '15m ago',
      'type': NotificationType.helpline,
      'isUnread': true,
      'category': 'Helpline',
      'date': 'Today',
    },
    {
      'title': 'Reimbursement Approved',
      'description':
          'Your travel expense claim for June 12 (Metro travel) has been processed.',
      'timeAgo': '1h ago',
      'type': NotificationType.reimbursement,
      'isUnread': false,
      'category': 'Reimbursements',
      'date': 'Today',
    },
    {
      'title': 'Donation Camp Success',
      'description':
          'Great work team! We collected 45 units at the Rajiv Chowk camp.',
      'timeAgo': 'Yesterday',
      'type': NotificationType.announcement,
      'isUnread': false,
      'category': 'All', // Announcement usually goes to all
      'date': 'Yesterday',
    },
    {
      'title': 'Missed Call Follow-up',
      'description':
          'System auto-assigned ticket #9901 for a missed call during off-hours.',
      'timeAgo': 'Yesterday',
      'type': NotificationType.missedCall,
      'isUnread': false,
      'category': 'Helpline',
      'date': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredNotifications = _selectedFilter == 'All'
        ? _allNotifications
        : _allNotifications
              .where(
                (n) =>
                    n['category'] == _selectedFilter || n['category'] == 'All',
              )
              .toList();

    final todayNotifications = filteredNotifications
        .where((n) => n['date'] == 'Today')
        .toList();
    final yesterdayNotifications = filteredNotifications
        .where((n) => n['date'] == 'Yesterday')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all as read')),
        ],
      ),
      body: Column(
        children: [
          NotificationFilterBar(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (todayNotifications.isNotEmpty) ...[
                  Text(
                    'TODAY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...todayNotifications.map(
                    (n) => NotificationCard(
                      title: n['title'],
                      description: n['description'],
                      timeAgo: n['timeAgo'],
                      type: n['type'],
                      isUnread: n['isUnread'],
                      tags: n['tags'],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (yesterdayNotifications.isNotEmpty) ...[
                  Text(
                    'YESTERDAY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...yesterdayNotifications.map(
                    (n) => NotificationCard(
                      title: n['title'],
                      description: n['description'],
                      timeAgo: n['timeAgo'],
                      type: n['type'],
                      isUnread: n['isUnread'],
                      tags: n['tags'],
                    ),
                  ),
                ],

                if (filteredNotifications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Theme.of(context).disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Notifications tab
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/helpline');
          if (index == 1) context.go('/helpline');
          // index 2 is current
          if (index == 3) context.go('/profile');
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
