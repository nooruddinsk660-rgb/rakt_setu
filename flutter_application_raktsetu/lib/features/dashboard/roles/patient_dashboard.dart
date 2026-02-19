import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/theme_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/app_drawer.dart';
import 'tabs/patient_home_tab.dart';
import 'tabs/requests_list_tab.dart';

class PatientDashboard extends ConsumerStatefulWidget {
  const PatientDashboard({super.key});

  @override
  ConsumerState<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends ConsumerState<PatientDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const PatientHomeTab(),
    const Center(child: Text('Donors Search - Coming Soon')),
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
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Find Donors'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
