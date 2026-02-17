import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_raktsetu/features/auth/login_screen.dart';
import 'package:flutter_application_raktsetu/shared/components/app_text_field.dart';
import 'package:flutter_application_raktsetu/shared/components/app_button.dart';

void main() {
  testWidgets('LoginScreen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    // Verify Title
    expect(find.text('RaktSetu'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);

    // Verify Inputs
    expect(find.byType(AppTextField), findsNWidgets(2)); // Email and Password
    expect(find.widgetWithText(AppTextField, 'Email Address'), findsOneWidget);
    expect(find.widgetWithText(AppTextField, 'Password'), findsOneWidget);

    // Verify Button
    expect(find.byType(AppButton), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
