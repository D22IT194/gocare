import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GoCare',
        ),
        centerTitle: true,

        actions: [
          IconButton(
            tooltip: 'Logout',

            onPressed:
                authProvider.isLoading
                    ? null
                    : () async {
                        await context
                            .read<AuthProvider>()
                            .logout();
                      },

            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                // =================================================
                // PROFILE ICON
                // =================================================

                const CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      Color(0xFFEAF4FF),

                  child: Icon(
                    Icons.person,
                    size: 45,
                    color:
                        Color(0xFF1976D2),
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // WELCOME
                // =================================================

                Text(
                  'Welcome to GoCare',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

                // =================================================
                // NAME
                // =================================================

                Text(
                  user?.displayName?.isNotEmpty ==
                          true
                      ? user!.displayName!
                      : 'User',

                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),

                const SizedBox(height: 6),

                // =================================================
                // EMAIL
                // =================================================

                Text(
                  user?.email ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 40),

                const Text(
                  'Your health and emergency assistance\n'
                  'starts here.',

                  textAlign:
                      TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}