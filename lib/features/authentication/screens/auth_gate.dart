import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (
          context,
          authProvider,
          child,
          ) {
        switch (authProvider.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case AuthStatus.authenticated:
            return const _AuthenticatedPlaceholder();

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return LoginScreen();
        }
      },
    );
  }
}

class _AuthenticatedPlaceholder extends StatelessWidget {
  const _AuthenticatedPlaceholder();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoCare'),
        actions: [
          IconButton(
            onPressed: () {
              authProvider.logout();
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                size: 80,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome to GoCare',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName!
                    : user?.email ?? '',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              const Text(
                'Home screen will be added in Phase 4.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}