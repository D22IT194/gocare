import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/nearby_place.dart';
import '../services/location_service.dart';
import '../services/nearby_places_service.dart';

enum NearbyStatus {
  initial,
  loading,
  success,
  error,
}

class NearbyProvider extends ChangeNotifier {
  NearbyProvider({
    LocationService? locationService,
    NearbyPlacesService? placesService,
  })  : _locationService =
            locationService ??
                const LocationService(),
        _placesService =
            placesService ??
                const NearbyPlacesService();

  final LocationService _locationService;
  final NearbyPlacesService _placesService;

  NearbyStatus _status =
      NearbyStatus.initial;

  Position? _currentPosition;

  List<NearbyPlace> _places = [];

  NearbyPlaceCategory?
      _selectedCategory;

  String? _errorMessage;

  NearbyStatus get status => _status;

  Position? get currentPosition =>
      _currentPosition;

  List<NearbyPlace> get places =>
      List.unmodifiable(_places);

  NearbyPlaceCategory?
      get selectedCategory =>
          _selectedCategory;

  String? get errorMessage =>
      _errorMessage;

  bool get isLoading =>
      _status == NearbyStatus.loading;

  bool get hasLocation =>
      _currentPosition != null;

  // ============================================================
  // LOAD LOCATION
  // ============================================================

  Future<bool> loadCurrentLocation() async {
    _status = NearbyStatus.loading;
    _errorMessage = null;

    notifyListeners();

    try {
      final position =
          await _locationService
              .getCurrentLocation();

      _currentPosition = position;

      _status =
          NearbyStatus.success;

      notifyListeners();

      return true;
    } on LocationServiceDisabledException {
      _setError(
        'Location services are turned off. '
        'Please enable GPS.',
      );

      return false;
    } on LocationPermissionDeniedException {
      _setError(
        'Location permission was denied.',
      );

      return false;
    } on LocationPermissionPermanentlyDeniedException {
      _setError(
        'Location permission is permanently denied. '
        'Please enable it from app settings.',
      );

      return false;
    } catch (_) {
      _setError(
        'Unable to get your current location.',
      );

      return false;
    }
  }

  // ============================================================
  // SEARCH PLACES
  // ============================================================

  Future<bool> searchPlaces(
    NearbyPlaceCategory category,
  ) async {
    if (_currentPosition == null) {
      final locationLoaded =
          await loadCurrentLocation();

      if (!locationLoaded) {
        return false;
      }
    }

    _selectedCategory = category;

    _status =
        NearbyStatus.loading;

    _errorMessage = null;

    _places = [];

    notifyListeners();

    try {
      final position =
          _currentPosition!;

      final results =
          await _placesService.searchNearby(
        latitude: position.latitude,
        longitude: position.longitude,
        category: category,
        radiusInMeters: 5000,
      );

      _places = results;

      _status =
          NearbyStatus.success;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );

      return false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    if (_selectedCategory != null) {
      await searchPlaces(
        _selectedCategory!,
      );

      return;
    }

    await loadCurrentLocation();
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<void> openLocationSettings() {
    return _locationService
        .openLocationSettings();
  }

  Future<void> openAppSettings() {
    return _locationService
        .openAppSettings();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearPlaces() {
    _places = [];
    _selectedCategory = null;

    _status =
        NearbyStatus.success;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    if (_status ==
        NearbyStatus.error) {
      _status =
          NearbyStatus.initial;
    }

    notifyListeners();
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _setError(
    String message,
  ) {
    _status =
        NearbyStatus.error;

    _errorMessage = message;

    notifyListeners();
  }
}