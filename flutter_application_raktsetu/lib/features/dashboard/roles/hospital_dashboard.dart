import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/theme_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_drawer.dart';
import 'tabs/hospital_home_tab.dart';
import 'tabs/requests_list_tab.dart';

class HospitalDashboard extends ConsumerStatefulWidget {
  const HospitalDashboard({super.key});

  @override
  ConsumerState<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends ConsumerState<HospitalDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HospitalHomeTab(),
    const Center(
      child: Text('Blood Bank View - Coming Soon'),
    ), // Could reuse BloodStockScreen here or link to it
    const RequestsListTab(),
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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(
            icon: Icon(Icons.bloodtype),
            label: 'Blood Bank',
          ),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
