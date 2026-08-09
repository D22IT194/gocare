import 'package:url_launcher/url_launcher.dart';

class MapLauncherService {
  const MapLauncherService();

  Future<bool> openLocation({
    required double latitude,
    required double longitude,
  }) async {
    // First try Google Maps app using geo URI.
  final geoUri = Uri.https(
  'www.google.com',
  '/maps/dir/',
  {
    'api': '1',
    'destination': '$latitude,$longitude',
    'travelmode': 'driving',
  },
);
    if (await canLaunchUrl(geoUri)) {
      return await launchUrl(
        geoUri,
        mode: LaunchMode.externalApplication,
      );
    }

    // Fallback to Google Maps web URL.
    final webUri = Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': '$latitude,$longitude',
      },
    );

    if (await canLaunchUrl(webUri)) {
      return await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }

  Future<bool> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    // Google Maps directions URL.
    final webUri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '$latitude,$longitude',
        'travelmode': 'driving',
      },
    );

    if (await canLaunchUrl(webUri)) {
      return await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    }

    // Android geo fallback.
    final geoUri = Uri.parse(
      'geo:$latitude,$longitude?q=$latitude,$longitude',
    );

    if (await canLaunchUrl(geoUri)) {
      return await launchUrl(
        geoUri,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }
}
