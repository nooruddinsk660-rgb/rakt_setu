import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/theme_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_drawer.dart';
import 'tabs/donor_home_tab.dart';
import 'tabs/donor_history_tab.dart';

class DonorDashboard extends ConsumerStatefulWidget {
  const DonorDashboard({super.key});

  @override
  ConsumerState<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends ConsumerState<DonorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    DonorHomeTab(),
    DonorHistoryTab(),
    Center(child: Text('Map View - Coming Soon')), // Placeholder for Nearby
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      drawer: const AppDrawer(),
      body: Column(
        children: [
          DashboardHeader(
            isDarkMode: isDarkMode,
            onThemeToggle: () {
              ref.read(themeModeProvider.notifier).state = isDarkMode
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 3) {
            context.push('/profile');
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Nearby'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
