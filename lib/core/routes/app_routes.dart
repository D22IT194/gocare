import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  // Startup
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String home = '/home';
  static const String firstAid = '/first-aid';
  static const String emergency = '/emergency';
  static const String nearby = '/nearby';
  static const String profile = '/profile';
  static const String blogs = '/blogs';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {};
  }
}