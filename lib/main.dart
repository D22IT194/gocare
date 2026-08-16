import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

import 'features/authentication/providers/auth_provider.dart';
import 'features/authentication/services/auth_service.dart';
import 'features/first_aid/providers/first_aid_provider.dart';
import 'features/blogs/providers/blog_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/emergency/providers/emergency_provider.dart';
import 'features/nearby/providers/nearby_provider.dart';
import 'features/healthcare/providers/doctor_provider.dart';
import 'features/healthcare/providers/healthcare_facility_provider.dart';
import 'features/healthcare/providers/nearby_doctor_provider.dart';
import 'features/profile/providers/settings_provider.dart';
import 'features/splash/screens/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GoCareBootstrap());
}

class GoCareBootstrap extends StatefulWidget {
  const GoCareBootstrap({super.key});

  @override
  State<GoCareBootstrap> createState() => _GoCareBootstrapState();
}

class _GoCareBootstrapState extends State<GoCareBootstrap> {
  bool _isReady = false;
  Object? _startupError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeApp());
    });
  }

  Future<void> _initializeApp() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isReady = true;
      });

      unawaited(
        Future<void>.delayed(const Duration(seconds: 2)).then((_) {
          return NotificationService.initialize();
        }),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _startupError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady && _startupError == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(navigateAfterDelay: false),
      );
    }

    if (_startupError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Text(
              'Unable to start GoCare. Please try again.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: AuthService()),
        ),

        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        ChangeNotifierProvider(create: (_) => BlogProvider()),

        ChangeNotifierProvider(create: (_) => FirstAidProvider()),

        ChangeNotifierProvider(create: (_) => EmergencyProvider()),

        ChangeNotifierProvider(create: (_) => NearbyProvider()),

        ChangeNotifierProvider(create: (_) => DoctorProvider()..loadDoctors()),

        ChangeNotifierProvider(create: (_) => HealthcareFacilityProvider()..loadFacilities()),

        ChangeNotifierProvider(create: (_) => NearbyDoctorProvider()),

        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
      ],
      child: const GoCareApp(),
    );
  }
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

      initialRoute: AppRoutes.auth,
      routes: AppRoutes.routes,
    );
  }
}
