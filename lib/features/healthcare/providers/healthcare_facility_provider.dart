import 'package:flutter/foundation.dart';

import '../models/healthcare_facility_model.dart';
import '../models/healthcare_facility_result.dart';
import '../models/healthcare_facility_filter.dart';
import '../services/healthcare_facility_service.dart';
import '../services/healthcare_distance_service.dart';
import '../services/saved_facility_service.dart';

import '../../nearby/services/location_service.dart';

class HealthcareFacilityProvider
    extends ChangeNotifier {
  HealthcareFacilityProvider({
    HealthcareFacilityService? service,
    SavedFacilityService? savedService,
    LocationService? locationService,
    HealthcareDistanceService? distanceService,
  })  : _service =
            service ??
                HealthcareFacilityService(),
        _savedService =
            savedService ??
                SavedFacilityService(),
        _locationService =
            locationService ??
                LocationService(),
        _distanceService =
            distanceService ??
                HealthcareDistanceService();

  // ============================================================
  // SERVICES
  // ============================================================

  final HealthcareFacilityService _service;

  final SavedFacilityService _savedService;

  final LocationService _locationService;

  final HealthcareDistanceService
      _distanceService;

  // ============================================================
  // DATA
  // ============================================================

  List<HealthcareFacilityModel>
      _facilities = [];

  Set<String> _savedFacilityIds = {};

  List<HealthcareFacilityResult>
      _nearbyFacilities = [];

  // ============================================================
  // LOADING / ERROR
  // ============================================================

  bool _loading = false;

  bool _locationLoading = false;

  String? _error;

  String? _locationError;

  // ============================================================
  // SEARCH
  // ============================================================

  String _searchQuery = '';

  // ============================================================
  // CATEGORY
  // ============================================================

  dynamic _selectedType;

  // ============================================================
  // SMART FILTER
  // ============================================================

  FacilityFilter _selectedFilter =
      FacilityFilter.all;

  // ============================================================
  // LOCATION
  // ============================================================

  double? _userLatitude;

  double? _userLongitude;

  double _nearbyRadiusKm = 10;

  // ============================================================
  // GETTERS
  // ============================================================

  List<HealthcareFacilityModel>
      get facilities =>
          List.unmodifiable(
            _facilities,
          );

  bool get loading => _loading;

  String? get error => _error;

  String get searchQuery =>
      _searchQuery;

  dynamic get selectedType =>
      _selectedType;

  FacilityFilter get selectedFilter =>
      _selectedFilter;

  Set<String> get savedFacilityIds =>
      Set.unmodifiable(
        _savedFacilityIds,
      );

  bool get hasSavedFacilities =>
      _savedFacilityIds.isNotEmpty;

  int get savedFacilityCount =>
      _savedFacilityIds.length;

  List<HealthcareFacilityResult>
      get nearbyFacilities =>
          List.unmodifiable(
            _nearbyFacilities,
          );

  List<HealthcareFacilityResult>
      get nearbyFilteredFacilities =>
          List.unmodifiable(
            _nearbyFacilities,
          );

  bool get locationLoading =>
      _locationLoading;

  String? get locationError =>
      _locationError;

  double? get userLatitude =>
      _userLatitude;

  double? get userLongitude =>
      _userLongitude;

  bool get hasLocation =>
      _userLatitude != null &&
      _userLongitude != null;

  double get nearbyRadiusKm =>
      _nearbyRadiusKm;

  // ============================================================
  // LOAD FACILITIES
  // ============================================================

  Future<void> loadFacilities() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      await Future.wait([
        _loadFacilitiesFromFirestore(),
        loadSavedFacilities(),
      ]);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  Future<void>
      _loadFacilitiesFromFirestore() async {
    _facilities =
        await _service.getFacilities();
  }

  // ============================================================
  // SAVED FACILITIES
  // ============================================================

  Future<void>
      loadSavedFacilities() async {
    _savedFacilityIds =
        await _savedService.getSavedIds();

    notifyListeners();
  }

  bool isSaved(
    String facilityId,
  ) {
    return _savedFacilityIds
        .contains(facilityId);
  }

  Future<void> toggleSaved(
    String facilityId,
  ) async {
    _savedFacilityIds =
        await _savedService.toggle(
      facilityId,
    );

    notifyListeners();
  }

  Future<void> removeSaved(
    String facilityId,
  ) async {
    _savedFacilityIds =
        await _savedService.remove(
      facilityId,
    );

    notifyListeners();
  }

  Future<void> clearSavedFacilities()
      async {
    await _savedService.clear();

    _savedFacilityIds = {};

    if (_selectedFilter ==
        FacilityFilter.saved) {
      _selectedFilter =
          FacilityFilter.all;
    }

    notifyListeners();
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void setSearchQuery(
    String query,
  ) {
    _searchQuery =
        query.trim();

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';

    notifyListeners();
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  void setSelectedType(
    dynamic type,
  ) {
    _selectedType = type;

    notifyListeners();
  }

  void setType(
    dynamic type,
  ) {
    setSelectedType(type);
  }

  void setEmergencyOnly(
    bool emergencyOnly,
  ) {
    if (emergencyOnly) {
      setFilter(FacilityFilter.emergency);
    } else {
      setFilter(FacilityFilter.all);
    }
  }

  void clearSelectedType() {
    _selectedType = null;

    notifyListeners();
  }

  // ============================================================
  // SMART FILTER
  // ============================================================

  void setFilter(
    FacilityFilter filter,
  ) {
    // Don't allow Saved when
    // there are no saved facilities.
    if (filter ==
            FacilityFilter.saved &&
        !hasSavedFacilities) {
      _selectedFilter =
          FacilityFilter.all;
    } else {
      _selectedFilter = filter;
    }

    notifyListeners();
  }

  void clearSmartFilter() {
    _selectedFilter =
        FacilityFilter.all;

    notifyListeners();
  }

  // ============================================================
  // SAVED FILTER AUTO RESET
  // ============================================================

  void _ensureValidFilter() {
    if (_selectedFilter ==
            FacilityFilter.saved &&
        !hasSavedFacilities) {
      _selectedFilter =
          FacilityFilter.all;
    }
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void>
      loadNearbyFacilities() async {
    _locationLoading = true;
    _locationError = null;

    notifyListeners();

    try {
      final position =
          await _locationService
              .getCurrentLocation();

      _userLatitude =
          position.latitude;

      _userLongitude =
          position.longitude;

      final results =
          <HealthcareFacilityResult>[];

      for (final facility
          in _facilities) {
        final distance =
            _distanceService
                .calculateDistanceKm(
          latitude1:
              _userLatitude!,
          longitude1:
              _userLongitude!,
          latitude2:
              facility.latitude,
          longitude2:
              facility.longitude,
        );

        if (distance <=
            _nearbyRadiusKm) {
          results.add(
            HealthcareFacilityResult(
              facility: facility,
              distanceKm: distance,
            ),
          );
        }
      }

      results.sort(
        (a, b) =>
            a.distanceKm.compareTo(
          b.distanceKm,
        ),
      );

      _nearbyFacilities =
          results;
    } catch (error) {
      _locationError =
          error.toString();

      _nearbyFacilities = [];
    } finally {
      _locationLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // NEARBY RADIUS
  // ============================================================

  void setNearbyRadius(
    double radiusKm,
  ) {
    _nearbyRadiusKm =
        radiusKm;

    if (hasLocation) {
      loadNearbyFacilities();
    }

    notifyListeners();
  }

  // ============================================================
  // BASE FILTERING
  //
  // Search + Category
  // ============================================================

  Iterable<HealthcareFacilityModel>
      _applyBaseFilters() {
    Iterable<HealthcareFacilityModel>
        result = _facilities;

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    if (_searchQuery.isNotEmpty) {
      final query =
          _searchQuery.toLowerCase();

      result = result.where(
        (facility) {
          final name =
              facility.name
                  .toLowerCase();

          final address =
              facility.address
                  .toLowerCase();

          final city =
              facility.city
                  .toLowerCase();

          final specialities =
              facility.specialities;

          final specialityMatch =
              specialities.any(
            (speciality) =>
                speciality
                    .toLowerCase()
                    .contains(query),
          );

          return name.contains(query) ||
              address.contains(query) ||
              city.contains(query) ||
              specialityMatch;
        },
      );
    }

    // ----------------------------------------------------------
    // CATEGORY
    // ----------------------------------------------------------

    if (_selectedType != null) {
      result = result.where(
        (facility) =>
            facility.type ==
            _selectedType,
      );
    }

    return result;
  }

  // ============================================================
  // VISIBLE FACILITIES
  //
  // THIS IS THE ONLY MAIN FILTER GETTER
  // ============================================================

  List<HealthcareFacilityModel>
      get visibleFacilities {
    _ensureValidFilter();

    final base =
        _applyBaseFilters();

    switch (_selectedFilter) {
      // --------------------------------------------------------
      // ALL
      // --------------------------------------------------------

      case FacilityFilter.all:
        return base.toList();

      // --------------------------------------------------------
      // EMERGENCY
      // --------------------------------------------------------

      case FacilityFilter.emergency:
        return base
            .where(
              (facility) =>
                  facility
                      .isEmergencyAvailable,
            )
            .toList();

      // --------------------------------------------------------
      // SAVED
      // --------------------------------------------------------

      case FacilityFilter.saved:
        return base
            .where(
              (facility) =>
                  _savedFacilityIds
                      .contains(
                facility.id,
              ),
            )
            .toList();

      // --------------------------------------------------------
      // NEARBY
      // --------------------------------------------------------

      case FacilityFilter.nearby:
        return _getNearbyVisibleFacilities(
          base,
        );
    }
  }

  // ============================================================
  // NEARBY FILTER
  // ============================================================

  List<HealthcareFacilityModel>
      _getNearbyVisibleFacilities(
    Iterable<HealthcareFacilityModel>
        base,
  ) {
    if (_nearbyFacilities.isEmpty) {
      return [];
    }

    final distanceMap = {
      for (final item
          in _nearbyFacilities)
        item.facility.id:
            item.distanceKm,
    };

    final nearbyIds =
        distanceMap.keys.toSet();

    final result = base
        .where(
          (facility) =>
              nearbyIds.contains(
            facility.id,
          ),
        )
        .toList();

    // Nearest first
    result.sort(
      (a, b) =>
          (distanceMap[a.id] ??
                  double.infinity)
              .compareTo(
        distanceMap[b.id] ??
            double.infinity,
      ),
    );

    return result;
  }

  // ============================================================
  // FILTERED FACILITIES
  //
  // BACKWARD-COMPATIBILITY GETTER
  // ============================================================

  List<HealthcareFacilityModel>
      get filteredFacilities {
    return visibleFacilities;
  }

  // ============================================================
  // SAVED FACILITIES
  // ============================================================

  List<HealthcareFacilityModel>
      get savedFacilities {
    return _facilities
        .where(
          (facility) =>
              _savedFacilityIds
                  .contains(
            facility.id,
          ),
        )
        .toList();
  }

  // ============================================================
  // EMERGENCY FACILITIES
  // ============================================================

  List<HealthcareFacilityModel>
      get emergencyFacilities {
    return _facilities
        .where(
          (facility) =>
              facility
                  .isEmergencyAvailable,
        )
        .toList();
  }

  // ============================================================
  // CLEAR EVERYTHING
  // ============================================================

  void resetFilters() {
    _searchQuery = '';

    _selectedType = null;

    _selectedFilter =
        FacilityFilter.all;

    notifyListeners();
  }
}