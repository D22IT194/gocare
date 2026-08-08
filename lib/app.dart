import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

class GoCareApp extends StatelessWidget {
  const GoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'GoCare',

      theme: AppTheme.lightTheme,

      home: const OnboardingScreen(),
    );
  }
}