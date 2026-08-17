import 'package:flutter/material.dart';

import '../../features/authentication/screens/auth_gate.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/emergency/screens/emergency_contacts_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/health_information_screen.dart';
import '../../features/profile/screens/medical_card_screen.dart';
import '../../features/profile/screens/medical_information_screen.dart';
import '../../features/profile/screens/profile_information_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/medical_equipment/screens/medical_equipment_screen.dart';
import '../../features/medicine/screens/medicine_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String auth = '/auth';
  static const String splash = '/splash';
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
  static const String medicalEquipment = '/medical-equipment';
  static const String medicine = '/medicine';
  static const String notifications = '/notifications';
  static const String healthInformation = '/health-information';
  static const String profileInformation = '/profile-information';
  static const String changePassword = '/change-password';
  static const String medicalInformation = '/medical-information';
  static const String medicalCard = '/medical-card';
  static const String emergencyContacts = '/emergency-contacts';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      auth: (_) => const AuthGate(),
      splash: (_) => const SplashScreen(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      forgotPassword: (_) => const ForgotPasswordScreen(),
      healthInformation: (_) => const HealthInformationScreen(),
      profileInformation: (_) => const ProfileInformationScreen(),
      changePassword: (_) => const ChangePasswordScreen(),
      medicalInformation: (_) => const MedicalInformationScreen(),
      medicalCard: (_) => const MedicalCardScreen(),
      emergencyContacts: (_) => const EmergencyContactsScreen(),
      settings: (_) => const SettingsScreen(),
      medicalEquipment: (_) => const MedicalEquipmentScreen(),
      medicine: (_) => const MedicinesScreen(),
    };
  }
}
