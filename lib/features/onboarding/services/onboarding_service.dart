import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _completedKey =
      'onboarding_completed';

  // ====================================================
  // CHECK STATUS
  // ====================================================

  Future<bool> isCompleted() async {
    final preferences =
        await SharedPreferences.getInstance();

    return preferences.getBool(
          _completedKey,
        ) ??
        false;
  }

  // ====================================================
  // MARK AS COMPLETED
  // ====================================================

  Future<void> complete() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setBool(
      _completedKey,
      true,
    );
  }

  // ====================================================
  // RESET
  // ====================================================
  //
  // Useful during development/testing.
  //
  // It allows you to show onboarding again.
  //

  Future<void> reset() async {
    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(
      _completedKey,
    );
  }
}