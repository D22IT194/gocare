import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'features/authentication/providers/auth_provider.dart';
// import 'features/authentication/screens/auth_gate.dart';
import 'features/authentication/services/auth_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
 MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        authService: AuthService(),
      ),
    ),
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

      initialRoute: AppRoutes.auth,
      routes: AppRoutes.routes,
    );
  }
}