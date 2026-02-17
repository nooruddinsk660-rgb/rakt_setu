import 'package:flutter/material.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/components/app_badge.dart';

class DonorCard extends StatelessWidget {
  final String name;
  final String location;
  final String distance;
  final String bloodGroup;
  final String lastDonated;
  final bool isVerified;
  final bool
  isAvailable; // 'Available Now' vs 'Recently Donated' (Waitlist logic)
  final String phoneNumber; // Masked
  final VoidCallback onContactTap;

  const DonorCard({
    super.key,
    required this.name,
    required this.location,
    required this.distance,
    required this.bloodGroup,
    required this.lastDonated,
    required this.phoneNumber,
    required this.onContactTap,
    this.isVerified = false,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF432828), const Color(0xFF251616)]
                            : [Colors.red.shade100, Colors.red.shade50],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.split(' ').take(2).map((e) => e[0]).join(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark
                            ? Colors.grey.shade300
                            : theme.primaryColor,
                      ),
                    ),
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$location, $distance',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppBadge(
                    text: bloodGroup,
                    isOutlined: true,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAvailable ? 'Available Now' : 'Recently Donated',
                    style: TextStyle(
                      fontSize: 10,
                      color: isAvailable ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF201212)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF331f1f)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAvailable)
                TextButton.icon(
                  onPressed: onContactTap,
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Contact'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : theme.primaryColor.withOpacity(0.05),
                    foregroundColor: theme.brightness == Brightness.dark
                        ? Colors.white
                        : theme.primaryColor,
                  ),
                )
              else
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Waitlist'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
