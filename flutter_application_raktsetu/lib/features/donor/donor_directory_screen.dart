import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/components/app_loader.dart';
import '../../shared/components/app_empty_state.dart';
import 'widgets/donor_search_filter.dart';
import 'widgets/donor_card.dart';
import 'widgets/contact_verification_modal.dart';

class DonorDirectoryScreen extends ConsumerStatefulWidget {
  const DonorDirectoryScreen({super.key});

  @override
  ConsumerState<DonorDirectoryScreen> createState() =>
      _DonorDirectoryScreenState();
}

class _DonorDirectoryScreenState extends ConsumerState<DonorDirectoryScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _donors = [];

  @override
  void initState() {
    super.initState();
    _loadMockData(); // Simulate initial fetch
  }

  Future<void> _loadMockData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _donors = [
          {
            'name': 'John Doe',
            'location': 'Downtown Metro',
            'distance': '2.5km',
            'bloodGroup': 'O+',
            'lastDonated': '2mo ago',
            'phoneNumber': '98XXXX4321',
            'isVerified': true,
            'isAvailable': true,
          },
          {
            'name': 'Alex Smith',
            'location': 'North Hills',
            'distance': '4.1km',
            'bloodGroup': 'A-',
            'lastDonated': 'Available Now',
            'phoneNumber': '21XXXX9876',
            'isVerified': false,
            'isAvailable': true,
          },
          {
            'name': 'Maria K.',
            'location': 'Westside',
            'distance': '8km',
            'bloodGroup': 'O+',
            'lastDonated': '1yr ago',
            'phoneNumber': '55XXXX1234',
            'isVerified': true,
            'isAvailable': true,
          },
          {
            'name': 'Robert T.',
            'location': 'East Bay',
            'distance': '12km',
            'bloodGroup': 'AB+',
            'lastDonated': 'Recently',
            'phoneNumber': '44XXXX5555',
            'isVerified': false,
            'isAvailable': false,
          },
        ];
      });
    }
  }

  void _handleSearch(String bloodGroup, String location) async {
    // Implement filtering logic or API call here
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Just shuffling/filtering mock data for demo
        _donors = _donors
            .where((d) => bloodGroup.isEmpty || d['bloodGroup'] == bloodGroup)
            .toList();
      });
    }
  }

  void _handleContact(String name) {
    ContactVerificationModal.show(
      context,
      donorName: name,
      onConfirm: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Calling $name...')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donor Search', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'BloodConnect Secure Directory',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show advanced filters
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
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_donors.length} Found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const AppLoader()
                : _donors.isEmpty
                ? const AppEmptyState(
                    message: 'No donors found',
                    icon: Icons.search_off,
                    subMessage: 'Try adjusting your filters',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _donors.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final donor = _donors[index];
                      return DonorCard(
                        name: donor['name'],
                        location: donor['location'],
                        distance: donor['distance'],
                        bloodGroup: donor['bloodGroup'],
                        lastDonated: donor['lastDonated'],
                        phoneNumber: donor['phoneNumber'],
                        isVerified: donor['isVerified'],
                        isAvailable: donor['isAvailable'],
                        onContactTap: () => _handleContact(donor['name']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
