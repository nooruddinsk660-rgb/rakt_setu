import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_raktsetu/core/theme/light_theme.dart';
import 'package:flutter_application_raktsetu/core/theme/dark_theme.dart';

// Simple provider for theme toggle (can be moved to a shared provider file)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(); // Logic handled in DashboardHeader for now
  }
}
