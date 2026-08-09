import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

import 'features/authentication/screens/forgot_password_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/register_screen.dart';

class GoCareApp extends StatelessWidget {
  const GoCareApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCare',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      initialRoute: AppRoutes.login,

      routes: {
        AppRoutes.login: (context) {
          return const LoginScreen();
        },

        AppRoutes.register: (context) {
          return const RegisterScreen();
        },

        AppRoutes.forgotPassword: (context) {
          return const ForgotPasswordScreen();
        },
      },
    );
  }
}