import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'features/authentication/providers/auth_provider.dart';
// import 'features/authentication/screens/auth_gate.dart';
import 'features/authentication/services/auth_service.dart';
import 'features/first_aid/providers/first_aid_provider.dart';

import 'firebase_options.dart';

import 'features/blogs/providers/blog_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/emergency/providers/emergency_provider.dart';
import 'features/nearby/providers/nearby_provider.dart';
import 'features/profile/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: AuthService()),
        ),

        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        ChangeNotifierProvider(create: (_) => BlogProvider()),
        ChangeNotifierProvider(create: (_) => FirstAidProvider()),
        ChangeNotifierProvider(
          create: (_) => EmergencyProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => NearbyProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
      ],
      child: const GoCareApp(),
    ),
  );
}

class GoCareApp extends StatelessWidget {
  const GoCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoCare',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<SettingsProvider>().themeMode,

      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
