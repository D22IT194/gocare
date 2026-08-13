import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/nearby_place.dart';
import '../services/location_service.dart';
import '../services/nearby_places_service.dart';
import '../services/nearby_saved_places_service.dart';
import '../models/nearby_category.dart';

enum NearbyStatus { initial, loading, success, error }

class NearbyProvider extends ChangeNotifier {
  NearbyProvider({
    LocationService? locationService,
    NearbyPlacesService? placesService,
    NearbySavedPlacesService? savedPlacesService,
  }) : _locationService = locationService ?? const LocationService(),
       _placesService = placesService ?? const NearbyPlacesService(),
       _savedPlacesService = savedPlacesService ?? NearbySavedPlacesService();

  // ==========================================================
  // SERVICES
  // ==========================================================

  final LocationService _locationService;

  final NearbyPlacesService _placesService;

  final NearbySavedPlacesService _savedPlacesService;

  // ==========================================================
  // STATE
  // ==========================================================

  NearbyStatus _status = NearbyStatus.initial;

  Position? _currentPosition;

  String? _locationName;

  String? _locationAddress;

  List<NearbyPlace> _places = [];

  List<NearbyPlace> _savedPlaces = [];

  NearbyPlaceCategory? _selectedCategory;

  String? _searchQuery;

  String? _errorMessage;

  List<LocationSuggestion> _locationSuggestions = [];

  bool _isSearchingLocations = false;

  bool _isLoadingSavedPlaces = false;

  Timer? _searchDebounce;

  // ==========================================================
  // GETTERS
  // ==========================================================

  NearbyStatus get status => _status;

  Position? get currentPosition => _currentPosition;

  String? get locationName => _locationName;

  String? get locationAddress => _locationAddress;

  List<NearbyPlace> get places => List.unmodifiable(_places);

  List<NearbyPlace> get savedPlaces => List.unmodifiable(_savedPlaces);

  NearbyPlaceCategory? get selectedCategory => _selectedCategory;

  String? get searchQuery => _searchQuery;

  String? get errorMessage => _errorMessage;

  List<LocationSuggestion> get locationSuggestions =>
      List.unmodifiable(_locationSuggestions);

  bool get isLoading => _status == NearbyStatus.loading;

  bool get isSearchingLocations => _isSearchingLocations;

  bool get isLoadingSavedPlaces => _isLoadingSavedPlaces;

  bool get hasLocation => _currentPosition != null;

  // ==========================================================
  // CURRENT LOCATION
  // ==========================================================

  Future<bool> loadCurrentLocation() async {
    _errorMessage = null;

    try {
      final position = await _locationService.getCurrentLocation();

      _currentPosition = position;

      await _loadLocationName(position.latitude, position.longitude);

      _status = NearbyStatus.success;

      notifyListeners();

      return true;
    } on LocationServiceDisabledException {
      _setError('Location services are turned off. Please enable GPS.');

      return false;
    } on LocationPermissionDeniedException {
      _setError('Location permission was denied.');

      return false;
    } on LocationPermissionPermanentlyDeniedException {
      _setError(
        'Location permission is permanently denied. Please enable it from app settings.',
      );

      return false;
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  // ==========================================================
  // LOCATION NAME
  // ==========================================================

  Future<void> _loadLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        _locationName = 'Current location';

        return;
      }

      final place = placemarks.first;

      final parts = <String>[];

      if ((place.subLocality ?? '').trim().isNotEmpty) {
        parts.add(place.subLocality!.trim());
      }

      if ((place.locality ?? '').trim().isNotEmpty) {
        parts.add(place.locality!.trim());
      }

      if ((place.administrativeArea ?? '').trim().isNotEmpty &&
          !parts.contains(place.administrativeArea)) {
        parts.add(place.administrativeArea!.trim());
      }

      _locationName = parts.isEmpty ? 'Current location' : parts.join(', ');

      _locationAddress =
          [place.street, place.subLocality, place.locality, place.postalCode]
              .where((value) => value != null && value.trim().isNotEmpty)
              .map((value) => value!.trim())
              .join(', ');
    } catch (_) {
      _locationName = 'Current location';
    }
  }

  // ==========================================================
  // LOCATION AUTOCOMPLETE
  // ==========================================================

  void searchLocationSuggestions(String query) {
    _searchDebounce?.cancel();

    if (query.trim().length < 2) {
      _locationSuggestions = [];

      _isSearchingLocations = false;

      notifyListeners();

      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      _isSearchingLocations = true;

      notifyListeners();

      try {
        _locationSuggestions = await _placesService.autocompleteLocation(
          query,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
        );
      } catch (e) {
        debugPrint('Location autocomplete error: $e');

        _locationSuggestions = [];
      } finally {
        _isSearchingLocations = false;

        notifyListeners();
      }
    });
  }

  void clearLocationSuggestions() {
    _searchDebounce?.cancel();

    _locationSuggestions = [];

    notifyListeners();
  }

  // ==========================================================
  // SELECT LOCATION
  // ==========================================================

  Future<bool> selectLocation(LocationSuggestion suggestion) async {
    try {
      _errorMessage = null;

      final selected = await _placesService.getPlaceLocation(
        suggestion.placeId,
      );

      _currentPosition = Position(
        longitude: selected.longitude,
        latitude: selected.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      _locationName = selected.name;

      _locationAddress = selected.address;

      _locationSuggestions = [];

      _places = [];

      _selectedCategory = null;

      _searchQuery = null;

      _status = NearbyStatus.success;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  // ==========================================================
  // CATEGORY SEARCH
  // ==========================================================

  Future<bool> searchPlaces(NearbyPlaceCategory category) async {
    if (_currentPosition == null) {
      final loaded = await loadCurrentLocation();

      if (!loaded) {
        return false;
      }
    }

    _selectedCategory = category;

    // Category selection is not a free-text search.
    // Keep the category active so the main search bar can search
    // for a specific place inside this category.
    _searchQuery = null;

    _status = NearbyStatus.loading;

    _errorMessage = null;

    notifyListeners();

    try {
      final position = _currentPosition!;

      List<NearbyPlace> results;

      if (_usesTextSearch(category)) {
        results = await _placesService.searchText(
          query: category.searchQuery,
          latitude: position.latitude,
          longitude: position.longitude,
          category: category,
        );
      } else {
        results = await _placesService.searchNearby(
          latitude: position.latitude,
          longitude: position.longitude,
          category: category,
          radiusInMeters: 5000,
        );
      }

      _places = await _applySavedState(results);

      _status = NearbyStatus.success;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));

      return false;
    }
  }

  // ==========================================================
  // TEXT SEARCH CATEGORIES
  // ==========================================================

  bool _usesTextSearch(NearbyPlaceCategory category) {
    switch (category) {
      case NearbyPlaceCategory.eyeCare:
      case NearbyPlaceCategory.mentalHealth:
      case NearbyPlaceCategory.cardiology:
      case NearbyPlaceCategory.pediatricCare:
      case NearbyPlaceCategory.orthopedic:
      case NearbyPlaceCategory.maternity:
      case NearbyPlaceCategory.diagnosticCenter:
      case NearbyPlaceCategory.emergency:
      case NearbyPlaceCategory.ambulance:
      case NearbyPlaceCategory.bloodBank:
      case NearbyPlaceCategory.rehabilitation:
      case NearbyPlaceCategory.homeHealthcare:
      case NearbyPlaceCategory.nursingService:
      case NearbyPlaceCategory.medicalEquipment:
        return true;

      default:
        return false;
    }
  }

  // ==========================================================
  // FREE TEXT SEARCH
  // ==========================================================

  Future<bool> searchText(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.length < 2) {
      return false;
    }

    if (_currentPosition == null) {
      final loaded = await loadCurrentLocation();

      if (!loaded) {
        return false;
      }
    }

    _status = NearbyStatus.loading;
    _errorMessage = null;
    _searchQuery = cleanQuery;

    // IMPORTANT:
    // Do NOT clear _selectedCategory here.
    // If the user selected Hospital and then searches "Apollo",
    // the search must remain inside the Hospital category.
    final category = _selectedCategory;

    notifyListeners();

    try {
      final position = _currentPosition!;

      final results = await _placesService.searchCategoryAndText(
        query: cleanQuery,
        latitude: position.latitude,
        longitude: position.longitude,
        category: category,
      );

      _places = await _applySavedState(results);

      _status = NearbyStatus.success;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));

      return false;
    }
  }

  // ==========================================================
  // LOAD SAVED PLACES
  // ==========================================================

  Future<void> loadSavedPlaces() async {
    if (_isLoadingSavedPlaces) {
      return;
    }

    _isLoadingSavedPlaces = true;

    // Don't change NearbyStatus here.
    // Saved places have their own loading state.
    notifyListeners();

    try {
      final saved = await _savedPlacesService.getSavedPlaces();

      _savedPlaces = List<NearbyPlace>.from(saved);

      // Update favorite state of
      // currently visible nearby places.
      _places = _places.map((place) {
        final savedPlace = _savedPlaces.any((item) => item.id == place.id);

        return place.copyWith(isFavorite: savedPlace);
      }).toList();

      _errorMessage = null;
    } catch (e) {
      debugPrint('Load saved places error: $e');

      _errorMessage = _cleanFirebaseError(e);
    } finally {
      _isLoadingSavedPlaces = false;

      notifyListeners();
    }
  }

  // ==========================================================
  // TOGGLE FAVORITE
  // ==========================================================

Future<bool> toggleFavorite(
  NearbyPlace place,
) async {
  final newValue =
      !place.isFavorite;

  debugPrint(
    '❤️ Favorite toggle: '
    '${place.name} '
    '${place.isFavorite} -> $newValue',
  );

  // Optimistic UI update.
  _updatePlaceFavorite(
    place.id,
    newValue,
  );

  notifyListeners();

  try {
    if (newValue) {
      // ==========================================
      // SAVE
      // ==========================================

      await _savedPlacesService.savePlace(
        place.copyWith(
          isFavorite: true,
        ),
      );

      // Update local saved list.
      _savedPlaces = [
        ..._savedPlaces.where(
          (item) => item.id != place.id,
        ),
        place.copyWith(
          isFavorite: true,
        ),
      ];

      debugPrint(
        '✅ Saved: ${place.id}',
      );
    } else {
      // ==========================================
      // REMOVE
      // ==========================================

      await _savedPlacesService.removePlace(
        place.id,
      );

      _savedPlaces =
          _savedPlaces.where(
        (item) => item.id != place.id,
      ).toList();

      debugPrint(
        '🗑️ Removed: ${place.id}',
      );
    }

    notifyListeners();

    return true;
  } catch (e) {
    debugPrint(
      '❌ Favorite operation failed: $e',
    );

    // Rollback UI.
    _updatePlaceFavorite(
      place.id,
      !newValue,
    );

    // Re-sync saved places from Firestore.
    try {
      _savedPlaces =
          await _savedPlacesService
              .getSavedPlaces();
    } catch (syncError) {
      debugPrint(
        '❌ Saved places sync failed: $syncError',
      );
    }

    _errorMessage =
        e.toString();

    notifyListeners();

    return false;
  }
}

  // ==========================================================
  // UPDATE FAVORITE IN NEARBY LIST
  // ==========================================================

  void _updatePlaceFavorite(String placeId, bool value) {
    _places = _places.map((place) {
      if (place.id == placeId) {
        return place.copyWith(isFavorite: value);
      }

      return place;
    }).toList();
  }

  // ==========================================================
  // APPLY SAVED STATE
  // ==========================================================

  Future<List<NearbyPlace>> _applySavedState(List<NearbyPlace> places) async {
    if (_savedPlaces.isEmpty) {
      try {
        _savedPlaces = await _savedPlacesService.getSavedPlaces();
      } catch (e) {
        debugPrint('Apply saved state error: $e');

        return places;
      }
    }

    return places.map((place) {
      final saved = _savedPlaces.any((item) => item.id == place.id);

      return place.copyWith(isFavorite: saved);
    }).toList();
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> refresh() async {
    await loadSavedPlaces();

    // If a place-name search is active, refresh that exact search first.
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      await searchText(_searchQuery!);

      return;
    }

    if (_selectedCategory != null) {
      await searchPlaces(_selectedCategory!);

      return;
    }

    await loadCurrentLocation();
  }

  // ==========================================================
  // SETTINGS
  // ==========================================================

  Future<void> openLocationSettings() {
    return _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() {
    return _locationService.openAppSettings();
  }

  // ==========================================================
  // CLEAR
  // ==========================================================

  void clearPlaces() {
    _places = [];

    _selectedCategory = null;

    _searchQuery = null;

    _status = NearbyStatus.success;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    if (_status == NearbyStatus.error) {
      _status = NearbyStatus.initial;
    }

    notifyListeners();
  }

  // ==========================================================
  // FIREBASE ERROR
  // ==========================================================

  String _cleanFirebaseError(Object error) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return 'Permission denied. Please check your Firestore security rules.';
    }

    if (message.contains('Missing or insufficient permissions')) {
      return 'Firestore permission denied. Check Firebase rules and login status.';
    }

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    return message;
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _setError(String message) {
    _status = NearbyStatus.error;

    _errorMessage = message;

    notifyListeners();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();

    super.dispose();
  }
}
