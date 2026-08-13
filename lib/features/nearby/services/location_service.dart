import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  // ------------------------------------------------------------
  // GET CURRENT LOCATION
  // ------------------------------------------------------------

  Future<Position> getCurrentLocation() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }

    // ----------------------------------------------------------
    // TRY LAST KNOWN LOCATION FIRST
    // ----------------------------------------------------------

    final lastKnownPosition =
        await Geolocator.getLastKnownPosition();

    if (lastKnownPosition != null) {
      // Return cached location immediately.
      //
      // This prevents the UI from waiting several seconds for
      // the GPS to acquire a fresh location.
      return lastKnownPosition;
    }

    // ----------------------------------------------------------
    // GET FRESH LOCATION
    // ----------------------------------------------------------

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      ),
    );
  }

  // ------------------------------------------------------------
  // GET FRESH HIGH ACCURACY LOCATION
  // ------------------------------------------------------------

  Future<Position> getFreshLocation() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  // ------------------------------------------------------------
  // CHECK LOCATION SERVICE
  // ------------------------------------------------------------

  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  // ------------------------------------------------------------
  // CHECK PERMISSION
  // ------------------------------------------------------------

  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  // ------------------------------------------------------------
  // REQUEST PERMISSION
  // ------------------------------------------------------------

  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  // ------------------------------------------------------------
  // OPEN LOCATION SETTINGS
  // ------------------------------------------------------------

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  // ------------------------------------------------------------
  // OPEN APP SETTINGS
  // ------------------------------------------------------------

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  // ------------------------------------------------------------
  // DISTANCE
  // ------------------------------------------------------------

  double distanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}

// ============================================================
// CUSTOM LOCATION EXCEPTIONS
// ============================================================

class LocationPermissionDeniedException
    implements Exception {
  const LocationPermissionDeniedException();

  @override
  String toString() {
    return 'Location permission was denied.';
  }
}

class LocationPermissionPermanentlyDeniedException
    implements Exception {
  const LocationPermissionPermanentlyDeniedException();

  @override
  String toString() {
    return 'Location permission was permanently denied.';
  }
}