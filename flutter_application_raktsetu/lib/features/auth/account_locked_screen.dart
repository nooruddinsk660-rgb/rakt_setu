import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/components/app_button.dart';

class AccountLockedScreen extends StatelessWidget {
  const AccountLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Color(0xFFD32F2F),
              ),
              const SizedBox(height: 24),
              Text(
                'Account Locked',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your account has been locked due to suspicious activity or multiple failed login attempts.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Please contact support or your administrator to unlock your account.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'support@raktsetu.org',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              AppButton(
                text: 'BACK TO LOGIN',
                isOutlined: true,
                onPressed: () {
                  Future.microtask(() => context.go('/login'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
