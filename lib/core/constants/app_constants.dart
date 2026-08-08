class AppConstants {
  AppConstants._();

  static const String appName = 'GoCare';

  static const String appVersion = '1.0.0';

  // App description
  static const String appDescription =
      'Your companion for first aid, emergency help and healthcare information.';

  // Emergency
  static const String emergencyRoute = '/emergency';

  // Default emergency labels.
  //
  // Actual phone numbers will later come from Firestore/Admin Panel.
  static const String ambulanceService = 'Ambulance';
  static const String policeService = 'Police';
  static const String fireService = 'Fire & Rescue';

  // Storage keys
  static const String onboardingCompletedKey = 'onboarding_completed';

  static const String userIdKey = 'user_id';

  static const String themeModeKey = 'theme_mode';
}