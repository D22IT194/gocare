import '../models/onboarding_model.dart';

class OnboardingProvider {
  const OnboardingProvider();

  List<OnboardingModel> get onboardingPages {
    return const [
      OnboardingModel(
        title: 'First Aid Help',
        description:
        'Learn what to do during common medical emergencies and access important first aid information quickly.',
        icon: '🩺',
        buttonText: 'Next',
      ),
      OnboardingModel(
        title: 'Emergency Assistance',
        description:
        'Get quick access to emergency services and important emergency contacts whenever you need help.',
        icon: '🚨',
        buttonText: 'Next',
      ),
      OnboardingModel(
        title: 'Find Nearby Care',
        description:
        'Find nearby hospitals, clinics, pharmacies and other healthcare services using your location.',
        icon: '📍',
        buttonText: 'Get Started',
      ),
    ];
  }
}