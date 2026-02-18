import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const DashboardHeader({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BloodConnect',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'Admin Console',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onThemeToggle,
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.grey,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              // const SizedBox(width: 12),
              // CircleAvatar(
              //   radius: 20,
              //   backgroundColor: Colors.grey.shade200,
              //   backgroundImage: const NetworkImage(
              //     'https://lh3.googleusercontent.com/aida-public/AB6AXuD-6xbNI-pmBdir66y7Li_SaKL5Nml2imLH7Mx0UEdULFwW-NUdKIMAEQIudHte56TMbBVyqEwIlLUH6LzEYEYMw_1FJQIvSDMW6ivNHcb1qs8quKuQC1U_id4RBAmUuYHBcVQRNT2P7id-tJrGyEFgFGTUgZua6JHnLftEZidFerISAMjVHBCC6D_Uyu-vbbawCSZ_yu8nl9X-c4PEg42noROHnguIQv7PFCS4NnR25xpNlXL_-BTbg8cQR1M00SrBi6lKuPL03xd0',
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
