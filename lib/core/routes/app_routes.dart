import 'package:flutter/material.dart';

import '../../features/authentication/screens/auth_gate.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Will be added in later phases.
  static const String home = '/home';
  static const String firstAid = '/first-aid';
  static const String emergency = '/emergency';
  static const String nearby = '/nearby';
  static const String profile = '/profile';
  static const String blogs = '/blogs';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      auth: (_) => const AuthGate(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
    };
  }
}