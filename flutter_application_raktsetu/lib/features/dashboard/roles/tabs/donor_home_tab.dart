import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/blood_request_card.dart';

class DonorHomeTab extends StatefulWidget {
  const DonorHomeTab({super.key});

  @override
  State<DonorHomeTab> createState() => _DonorHomeTabState();
}

class _DonorHomeTabState extends State<DonorHomeTab> {
  bool _isAvailable = true;
  String? _currentAddress;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      // In a real app, use Geocoding to get address.
      // For now just showing Lat/Lng or "Current Location"
      if (mounted) {
        setState(() {
          _currentAddress =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Header
          if (_currentAddress != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Location: $_currentAddress',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

          // Availability Toggle
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Availability Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _isAvailable
                            ? 'You are available to donate'
                            : 'You are currently unavailable',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _isAvailable ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() {
                        _isAvailable = value;
                      });
                      // TODO: Sync with backend
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nearby Requests',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Dummy Requests List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return BloodRequestCard(
                patientName: 'Patient #$index',
                hospitalName: 'General Hospital $index',
                distance: '${(index + 1) * 2.5} km',
                bloodGroup: 'O+',
                urgency: index == 0
                    ? RequestUrgency.critical
                    : RequestUrgency.high,
                timeAgo: '${index + 1}h ago',
                onAccept: () {
                  // TODO: Handle accept
                },
                onIgnore: () {
                  // TODO: Handle ignore
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
