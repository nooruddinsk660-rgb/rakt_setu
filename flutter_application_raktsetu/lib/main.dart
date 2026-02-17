import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'navigation/app_router.dart';
import 'shared/providers/theme_provider.dart';
import 'core/errors/error_logger.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        ErrorLogger.logError(details.exception, details.stack);
      };

      runApp(const ProviderScope(child: RaktSetuApp()));
    },
    (error, stack) {
      ErrorLogger.logError(error, stack);
    },
  );
}

class RaktSetuApp extends ConsumerWidget {
  const RaktSetuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'RaktSetu',
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        // Global Error Widget
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'An unexpected error occurred.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}
