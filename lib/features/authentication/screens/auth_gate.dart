import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../../home/screens/home_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../onboarding/services/onboarding_service.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../core/navigation/app_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final OnboardingService _onboardingService =
      OnboardingService();

  bool _isCheckingOnboarding = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();

    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final completed =
        await _onboardingService.isCompleted();

    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = completed;
      _isCheckingOnboarding = false;
    });
  }

  void _onboardingFinished() {
    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------
    // Check onboarding
    // --------------------------------

    if (_isCheckingOnboarding) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // --------------------------------
    // Show onboarding
    // --------------------------------

    if (!_onboardingCompleted) {
      return OnboardingScreen(
        onFinished: _onboardingFinished,
      );
    }

    // --------------------------------
    // Check authentication
    // --------------------------------

    final authProvider =
        context.watch<AuthProvider>();

    if (authProvider.status == AuthStatus.initial ||
        authProvider.status == AuthStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // --------------------------------
    // Authenticated → Home
    // --------------------------------

 if (authProvider.isAuthenticated) {
  return AppShell();
}

    // --------------------------------
    // Not authenticated → Login
    // --------------------------------

    return const LoginScreen();
  }
}