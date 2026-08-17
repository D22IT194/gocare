import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../emergency/models/emergency_contact.dart';
import '../../emergency/services/emergency_service.dart';
import '../../profile/models/health_information.dart';
import '../../profile/services/profile_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    FirebaseAuth? firebaseAuth,
    EmergencyService? emergencyService,
    ProfileService? profileService,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _emergencyService = emergencyService ?? EmergencyService(),
       _profileService = profileService ?? ProfileService() {
    _listenToAuthChanges();
  }

  final FirebaseAuth _firebaseAuth;
  final EmergencyService _emergencyService;
  final ProfileService _profileService;

  StreamSubscription<User?>? _authSubscription;

  String? _userId;

  // ============================================================
  // PRIMARY CONTACTS
  // ============================================================

  List<EmergencyContact> _primaryContacts = [];

  bool _isLoadingPrimaryContacts = false;

  String? _primaryContactsError;

  // ============================================================
  // HEALTH INFORMATION
  // ============================================================

  HealthInformation? _healthInformation;

  bool _isLoadingHealthInformation = false;

  String? _healthInformationError;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  bool _initialized = false;

  bool _isInitializing = false;

  // ============================================================
  // GETTERS
  // ============================================================

  String? get userId => _userId;

  List<EmergencyContact> get primaryContacts =>
      List.unmodifiable(_primaryContacts);

  HealthInformation? get healthInformation => _healthInformation;

  bool get isLoadingPrimaryContacts => _isLoadingPrimaryContacts;

  bool get isLoadingHealthInformation => _isLoadingHealthInformation;

  bool get healthInformationLoading => _isLoadingHealthInformation;

  String? get primaryContactsError => _primaryContactsError;

  String? get healthInformationError => _healthInformationError;

  bool get initialized => _initialized;

  bool get isLoading =>
      _isInitializing ||
      _isLoadingPrimaryContacts ||
      _isLoadingHealthInformation;

  // ============================================================
  // PRIMARY CONTACT HELPERS
  // ============================================================

  EmergencyContact? get primaryPersonalContact {
    for (final contact in _primaryContacts) {
      if (contact.type == EmergencyContactType.personal) {
        return contact;
      }
    }

    return null;
  }

  EmergencyContact? get primaryDoctorContact {
    for (final contact in _primaryContacts) {
      if (contact.type == EmergencyContactType.doctor) {
        return contact;
      }
    }

    return null;
  }

  bool get hasPrimaryContact => _primaryContacts.isNotEmpty;

  bool get hasPersonalPrimaryContact => primaryPersonalContact != null;

  bool get hasDoctorPrimaryContact => primaryDoctorContact != null;

  // ============================================================
  // HEALTH INFORMATION
  // ============================================================

  bool get hasHealthInformation {
    return _healthInformation != null;
  }

  bool get isHealthInformationComplete {
    final health = _healthInformation;

    if (health == null) {
      return false;
    }

    // Personal information
    final personalInformationComplete =
        health.dateOfBirth != null &&
        _hasValue(health.gender) &&
        _hasValue(health.bloodGroup) &&
        health.height != null &&
        health.weight != null;

    // Medical information
    final medicalInformationComplete =
        _hasValue(health.allergies) &&
        _hasValue(health.medicalConditions) &&
        _hasValue(health.currentMedications);

    // Emergency information
    final emergencyInformationComplete = _hasValue(health.emergencyNotes);

    return personalInformationComplete &&
        medicalInformationComplete &&
        emergencyInformationComplete;
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // ============================================================
  // AUTH LISTENER
  // ============================================================

  void _listenToAuthChanges() {
    _authSubscription = _firebaseAuth.authStateChanges().listen((user) async {
      if (user == null) {
        _clearLocalState();

        return;
      }

      await initialize(userId: user.uid, force: true);
    });
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize({required String userId, bool force = false}) async {
    // ----------------------------------------------------------
    // IMPORTANT
    //
    // If HomeProvider already loaded data for this user,
    // don't hit Firestore again.
    // ----------------------------------------------------------

    if (!force && _initialized && _userId == userId) {
      debugPrint('HomeProvider: already initialized.');

      return;
    }

    if (_isInitializing) {
      debugPrint('HomeProvider: initialization already running.');

      return;
    }

    _isInitializing = true;

    _userId = userId;

    _primaryContactsError = null;
    _healthInformationError = null;

    notifyListeners();

    try {
      // --------------------------------------------------------
      // Load both at the same time.
      // --------------------------------------------------------

      await Future.wait([
        _loadPrimaryContacts(userId: userId),
        _loadHealthInformation(userId: userId),
      ]);

      _initialized = true;
    } finally {
      _isInitializing = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD PRIMARY CONTACTS
  // ============================================================

  Future<void> _loadPrimaryContacts({required String userId}) async {
    _isLoadingPrimaryContacts = true;
    _primaryContactsError = null;

    notifyListeners();

    try {
      final contacts = await _emergencyService.getContacts(userId: userId);

      _primaryContacts = contacts
          .where((contact) => contact.isPrimary)
          .toList();

      debugPrint(
        'HomeProvider: '
        '${_primaryContacts.length} primary contacts loaded.',
      );
    } catch (e, stackTrace) {
      debugPrint('HomeProvider primary contacts error: $e');

      debugPrint('$stackTrace');

      _primaryContactsError = 'Unable to load primary contacts.';

      _primaryContacts = [];
    } finally {
      _isLoadingPrimaryContacts = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD HEALTH INFORMATION
  // ============================================================

  Future<void> _loadHealthInformation({required String userId}) async {
    _isLoadingHealthInformation = true;
    _healthInformationError = null;

    notifyListeners();

    try {
      _healthInformation = await _profileService.getHealthInformation(
        userId: userId,
      );

      debugPrint('HomeProvider: health information loaded.');
    } catch (e, stackTrace) {
      debugPrint('HomeProvider health information error: $e');

      debugPrint('$stackTrace');

      _healthInformationError = 'Unable to load health information.';

      _healthInformation = null;
    } finally {
      _isLoadingHealthInformation = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH PRIMARY CONTACTS
  // ============================================================

  // ============================================================
  // REFRESH PRIMARY CONTACTS
  // ============================================================

  Future<void> refreshPrimaryContacts() async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    try {
      final contacts = await _emergencyService.getContacts(userId: userId);

      // Keep ONLY primary contacts.
      _primaryContacts = contacts
          .where((contact) => contact.isPrimary)
          .toList();

      _primaryContactsError = null;

      debugPrint(
        'HomeProvider: '
        '${_primaryContacts.length} primary contacts refreshed.',
      );

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('HomeProvider refresh primary contacts error: $e');

      debugPrint('$stackTrace');

      _primaryContactsError = 'Unable to refresh primary contacts.';

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH HEALTH INFORMATION
  // ============================================================

  Future<void> refreshHealthInformation() async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    try {
      final healthInformation = await _profileService.getHealthInformation(
        userId: userId,
      );

      _healthInformation = healthInformation;
      _healthInformationError = null;

      notifyListeners();
    } catch (error) {
      _healthInformationError = error.toString();

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH HOME DATA
  // ============================================================

  Future<void> refresh() async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    await Future.wait([
      _loadPrimaryContacts(userId: userId),
      _loadHealthInformation(userId: userId),
    ]);

    _initialized = true;

    notifyListeners();
  }

  // ============================================================
  // CALL WHEN PRIMARY CONTACT CHANGED
  // ============================================================

  Future<void> onPrimaryContactChanged() async {
    await refreshPrimaryContacts();
  }

  // ============================================================
  // CALL WHEN HEALTH INFORMATION CHANGED
  // ============================================================

  Future<void> onHealthInformationChanged() async {
    await refreshHealthInformation();
  }

  // ============================================================
  // CLEAR LOCAL STATE
  // ============================================================

  void _clearLocalState() {
    _userId = null;

    _primaryContacts = [];

    _healthInformation = null;

    _primaryContactsError = null;

    _healthInformationError = null;

    _isLoadingPrimaryContacts = false;

    _isLoadingHealthInformation = false;

    _initialized = false;

    _isInitializing = false;

    notifyListeners();
  }

  // ============================================================
  // PUBLIC CLEAR
  // ============================================================

  void clear() {
    _clearLocalState();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _authSubscription?.cancel();

    super.dispose();
  }
}
