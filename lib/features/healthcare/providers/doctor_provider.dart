import 'package:flutter/foundation.dart';

import '../models/doctor_model.dart';
import '../models/doctor_filter_model.dart';
import '../models/nearby_doctor_model.dart';
import '../models/speciality_model.dart';
import '../services/doctor_service.dart';

class DoctorProvider extends ChangeNotifier {
  DoctorProvider({
    DoctorService? service,
  }) : _service =
            service ?? DoctorService();

  // ============================================================
  // SERVICE
  // ============================================================

  final DoctorService _service;

  // ============================================================
  // ALL DOCTORS
  // ============================================================

  List<DoctorModel> _doctors = [];

  // ============================================================
  // DOCTORS OF A PARTICULAR FACILITY
  // ============================================================

  List<DoctorModel> _facilityDoctors = [];

  bool _facilityDoctorsLoading = false;

  String? _facilityDoctorsError;

  // ============================================================
  // NEARBY DOCTORS
  // ============================================================

  List<NearbyDoctorModel> _nearbyDoctors = [];

  bool _nearbyDoctorsLoading = false;

  String? _nearbyDoctorsError;

  // ============================================================
  // SAVED DOCTORS
  // ============================================================

  final Set<String> _savedDoctorIds = {};

  // ============================================================
  // MAIN LOADING / ERROR
  // ============================================================

  bool _loading = false;

  String? _error;

  // ============================================================
  // SEARCH
  // ============================================================

  String _searchQuery = '';

  // ============================================================
  // SPECIALITY
  // ============================================================

  String _selectedSpeciality = 'All';

  String? _selectedSpecialityId;

  // ============================================================
  // DOCTOR FILTER
  // ============================================================

  DoctorFilterModel _filter =
      DoctorFilterModel.empty;

  // ============================================================
  // LOCATION
  // ============================================================

  double? _userLatitude;

  double? _userLongitude;

  double _nearbyRadiusKm = 10;

  // ============================================================
  // GETTERS
  // ============================================================

  List<DoctorModel> get doctors =>
      List.unmodifiable(
        _doctors,
      );

  List<DoctorModel> get featuredDoctors =>
      _doctors
          .where(
            (doctor) =>
                doctor.isFeatured,
          )
          .toList();

  List<DoctorModel> get facilityDoctors =>
      List.unmodifiable(
        _facilityDoctors,
      );

  List<NearbyDoctorModel>
      get nearbyDoctors =>
          List.unmodifiable(
            _nearbyDoctors,
          );

  bool get loading =>
      _loading;

  String? get error =>
      _error;

  String get searchQuery =>
      _searchQuery;

  String get selectedSpeciality =>
      _selectedSpeciality;

  String? get selectedSpecialityId =>
      _selectedSpecialityId;

  DoctorFilterModel get filter =>
      _filter;

  // ============================================================
  // FACILITY DOCTORS GETTERS
  // ============================================================

  bool get facilityDoctorsLoading =>
      _facilityDoctorsLoading;

  String? get facilityDoctorsError =>
      _facilityDoctorsError;

  // ============================================================
  // NEARBY GETTERS
  // ============================================================

  bool get nearbyDoctorsLoading =>
      _nearbyDoctorsLoading;

  String? get nearbyDoctorsError =>
      _nearbyDoctorsError;

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
  // SAVED DOCTORS GETTERS
  // ============================================================

  Set<String> get savedDoctorIds =>
      Set.unmodifiable(
        _savedDoctorIds,
      );

  bool get hasSavedDoctors =>
      _savedDoctorIds.isNotEmpty;

  int get savedDoctorCount =>
      _savedDoctorIds.length;

  bool isSaved(
    String doctorId,
  ) {
    return _savedDoctorIds
        .contains(doctorId);
  }

  // ============================================================
  // LOAD ALL DOCTORS
  // ============================================================

  Future<void> loadDoctors() async {
    _loading = true;
    _error = null;

    notifyListeners();

    try {
      _doctors =
          await _service.getDoctors();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD DOCTORS BY FACILITY
  // ============================================================

  Future<void> loadDoctorsByFacility(
    String facilityId,
  ) async {
    _facilityDoctorsLoading =
        true;

    _facilityDoctorsError =
        null;

    notifyListeners();

    try {
      _facilityDoctors =
          await _service
              .getDoctorsByFacility(
        facilityId,
      );
    } catch (error) {
      _facilityDoctorsError =
          error.toString();

      _facilityDoctors = [];
    } finally {
      _facilityDoctorsLoading =
          false;

      notifyListeners();
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void setSearchQuery(
    String value,
  ) {
    _searchQuery =
        value.trim();

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';

    notifyListeners();
  }

  // ============================================================
  // SPECIALITY
  // ============================================================

  void setSpeciality(
    String speciality,
  ) {
    _selectedSpeciality =
        speciality;

    notifyListeners();
  }

  void selectSpeciality(
    String? specialityId,
  ) {
    _selectedSpecialityId =
        specialityId;

    notifyListeners();
  }

  void clearSpeciality() {
    _selectedSpeciality =
        'All';
    _selectedSpecialityId =
        null;

    notifyListeners();
  }

  // ============================================================
  // SPECIALITIES
  // ============================================================

  List<SpecialityModel> get specialities {
    final Map<String, SpecialityModel> map = {};

    for (final doctor in _doctors) {
      if (doctor.specialityId.isNotEmpty &&
          doctor.specialityName.isNotEmpty) {
        map.putIfAbsent(
          doctor.specialityId,
          () => SpecialityModel(
            id: doctor.specialityId,
            name: doctor.specialityName,
            icon: 'medical_services',
            isActive: true,
            sortOrder: 0,
          ),
        );
      }
    }

    final list = map.values.toList();

    list.sort(
      (a, b) => a.name.compareTo(b.name),
    );

    return list;
  }

  // ============================================================
  // FILTER
  // ============================================================

  void setFilter(
    DoctorFilterModel filter,
  ) {
    _filter = filter;

    notifyListeners();
  }

  void clearFilters() {
    _filter =
        DoctorFilterModel.empty;

    _selectedSpeciality =
        'All';

    _selectedSpecialityId =
        null;

    _searchQuery = '';

    notifyListeners();
  }

  // ============================================================
  // SAVED DOCTORS
  // ============================================================
  //
  // Temporary in-memory implementation.
  //
  // Later connect this to:
  // Firestore / SharedPreferences
  // depending on your app architecture.
  //
  // ============================================================

  void toggleSaved(
    String doctorId,
  ) {
    if (_savedDoctorIds
        .contains(doctorId)) {
      _savedDoctorIds
          .remove(doctorId);
    } else {
      _savedDoctorIds
          .add(doctorId);
    }

    notifyListeners();
  }

  void removeSaved(
    String doctorId,
  ) {
    _savedDoctorIds
        .remove(doctorId);

    notifyListeners();
  }

  void clearSavedDoctors() {
    _savedDoctorIds.clear();

    notifyListeners();
  }

  // ============================================================
  // FILTERED DOCTORS
  // ============================================================

  List<DoctorModel>
      get filteredDoctors {
    Iterable<DoctorModel> result =
        _doctors;

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    if (_searchQuery.isNotEmpty) {
      final query =
          _searchQuery.toLowerCase();

      result = result.where(
        (doctor) {
          return doctor.name
                  .toLowerCase()
                  .contains(query) ||
              doctor.specialityName
                  .toLowerCase()
                  .contains(query) ||
              doctor.clinicName
                  .toLowerCase()
                  .contains(query);
        },
      );
    }

    // ----------------------------------------------------------
    // SPECIALITY
    // ----------------------------------------------------------

    if (_selectedSpecialityId != null) {
      result = result.where(
        (doctor) =>
            doctor.specialityId ==
            _selectedSpecialityId,
      );
    } else if (_selectedSpeciality !=
        'All') {
      result = result.where(
        (doctor) =>
            doctor.specialityName ==
            _selectedSpeciality,
      );
    }

    // ----------------------------------------------------------
    // MINIMUM RATING
    // ----------------------------------------------------------

    if (_filter.minRating !=
        null) {
      result = result.where(
        (doctor) =>
            doctor.rating >=
            _filter.minRating!,
      );
    }

    // ----------------------------------------------------------
    // MINIMUM EXPERIENCE
    // ----------------------------------------------------------

    if (_filter
            .minExperienceYears !=
        null) {
      result = result.where(
        (doctor) =>
            doctor.experienceYears >=
            _filter
                .minExperienceYears!,
      );
    }

    // ----------------------------------------------------------
    // MAX CONSULTATION FEE
    // ----------------------------------------------------------

    if (_filter
            .maxConsultationFee !=
        null) {
      result = result.where(
        (doctor) =>
            doctor.consultationFee <=
            _filter
                .maxConsultationFee!,
      );
    }

    // ----------------------------------------------------------
    // VERIFIED
    // ----------------------------------------------------------

    if (_filter.verifiedOnly) {
      result = result.where(
        (doctor) =>
            doctor.isVerified,
      );
    }

    // ----------------------------------------------------------
    // APPOINTMENT AVAILABLE
    // ----------------------------------------------------------

    if (_filter
        .appointmentAvailable) {
      result = result.where(
        (doctor) =>
            doctor.appointmentEnabled,
      );
    }

    // ----------------------------------------------------------
    // SORT
    // ----------------------------------------------------------

    final list =
        result.toList();

    list.sort(
      (a, b) =>
          b.rating.compareTo(
        a.rating,
      ),
    );

    return list;
  }

  // ============================================================
  // SAVED DOCTORS
  // ============================================================

  List<DoctorModel>
      get savedDoctors {
    return _doctors
        .where(
          (doctor) =>
              _savedDoctorIds
                  .contains(
            doctor.id,
          ),
        )
        .toList();
  }

  // ============================================================
  // NEARBY DOCTORS
  // ============================================================
  //
  // Your NearbyDoctorModel is already present,
  // so this provider simply exposes it.
  //
  // The actual location calculation should remain
  // inside DoctorService / location service.
  //
  // ============================================================

  void setNearbyDoctors(
    List<NearbyDoctorModel>
        doctors,
  ) {
    _nearbyDoctors =
        List.unmodifiable(
      doctors,
    );

    notifyListeners();
  }

  void clearNearbyDoctors() {
    _nearbyDoctors = [];

    notifyListeners();
  }

  // ============================================================
  // NEARBY RADIUS
  // ============================================================

  void setNearbyRadius(
    double radiusKm,
  ) {
    _nearbyRadiusKm =
        radiusKm;

    notifyListeners();
  }

  // ============================================================
  // RESET EVERYTHING
  // ============================================================

  void reset() {
    _searchQuery = '';

    _selectedSpeciality =
        'All';

    _filter =
        DoctorFilterModel.empty;

    notifyListeners();
  }
}