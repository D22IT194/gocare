import 'package:url_launcher/url_launcher.dart';

class EmergencyCallService {
  const EmergencyCallService();

  Future<bool> call(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanedNumber.isEmpty) {
      return false;
    }

    final uri = Uri(scheme: 'tel', path: cleanedNumber);

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(uri);
  }
}
