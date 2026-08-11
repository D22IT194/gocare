import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/emergency_contact.dart';
import '../services/emergency_service.dart';

class EmergencyProvider extends ChangeNotifier {
  EmergencyProvider({
    EmergencyService? emergencyService,
    FirebaseAuth? firebaseAuth,
  })  : _emergencyService =
            emergencyService ?? EmergencyService(),
        _firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance {
    _listenToAuthChanges();
  }

  final EmergencyService _emergencyService;

  final FirebaseAuth _firebaseAuth;

  final List<EmergencyContact> _contacts = [];

  StreamSubscription<User?>? _authSubscription;

  bool _isLoading = false;

  String? _errorMessage;

  String? _userId;

  // ============================================================
  // GETTERS
  // ============================================================

  List<EmergencyContact> get contacts =>
      List.unmodifiable(_contacts);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get userId => _userId;

  // ============================================================
  // CONTACTS BY TYPE
  // ============================================================

  List<EmergencyContact> contactsByType(
    EmergencyContactType type,
  ) {
    return _contacts
        .where(
          (contact) => contact.type == type,
        )
        .toList(growable: false);
  }

  // ============================================================
  // PRIMARY CONTACT
  // ============================================================

  EmergencyContact? get primaryContact {
    try {
      return _contacts.firstWhere(
        (contact) => contact.isPrimary,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // AUTH LISTENER
  // ============================================================

  void _listenToAuthChanges() {
    _authSubscription =
        _firebaseAuth.authStateChanges().listen(
      (User? user) async {
        debugPrint(
          'EmergencyProvider: Auth state changed',
        );

        if (user == null) {
          // ======================================================
          // USER LOGGED OUT
          // ======================================================

          debugPrint(
            'EmergencyProvider: User logged out.',
          );

          _userId = null;

          _contacts.clear();

          _isLoading = false;

          _errorMessage = null;

          notifyListeners();

          return;
        }

        // ========================================================
        // USER LOGGED IN
        // ========================================================

        debugPrint(
          'EmergencyProvider: '
          'User logged in: ${user.uid}',
        );

        await initialize(
          userId: user.uid,
        );
      },
    );
  }

  // ============================================================
  // INITIALIZE / LOAD CONTACTS
  // ============================================================

  Future<void> initialize({
    required String userId,
  }) async {
    // Prevent unnecessary reload for same user
    // if contacts are already loaded.
    if (_userId == userId &&
        !_isLoading &&
        _contacts.isNotEmpty) {
      debugPrint(
        'EmergencyProvider: '
        'Contacts already loaded for $userId',
      );

      return;
    }

    _userId = userId;

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      debugPrint(
        'EmergencyProvider: '
        'Loading contacts from Firestore...',
      );

      final loadedContacts =
          await _emergencyService.getContacts(
        userId: userId,
      );

      // Important:
      // Clear old contacts before inserting
      // contacts belonging to current user.
      _contacts
        ..clear()
        ..addAll(loadedContacts);

      debugPrint(
        'EmergencyProvider: '
        '${loadedContacts.length} contacts loaded.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'EmergencyProvider load error: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _errorMessage =
          'Unable to load emergency contacts.';

      _contacts.clear();
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ADD CONTACT
  // ============================================================

  Future<bool> addContact({
    required String name,
    required String phone,
    EmergencyContactType type =
        EmergencyContactType.personal,
    String? relationship,
    String? email,
    String? speciality,
    String? address,
    bool isPrimary = false,
  }) async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage =
          'User is not logged in.';

      notifyListeners();

      return false;
    }

    try {
      _errorMessage = null;

      final contact = EmergencyContact(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),

        name: name.trim(),

        phone: phone.trim(),

        type: type,

        relationship: _clean(
          relationship,
        ),

        email: _clean(
          email,
        ),

        speciality: _clean(
          speciality,
        ),

        address: _clean(
          address,
        ),

        isPrimary: isPrimary,
      );

      // ========================================================
      // PRIMARY CONTACT
      // ========================================================

      if (isPrimary) {
        for (var i = 0;
            i < _contacts.length;
            i++) {
          if (_contacts[i].isPrimary) {
            _contacts[i] =
                _contacts[i].copyWith(
              isPrimary: false,
            );
          }
        }
      }

      // ========================================================
      // FIRESTORE
      // ========================================================

      await _emergencyService.addContact(
        userId: userId,
        contact: contact,
      );

      // ========================================================
      // LOCAL STATE
      // ========================================================

      _contacts.add(contact);

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'EmergencyProvider add error: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _errorMessage =
          'Unable to save emergency contact.';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // UPDATE CONTACT
  // ============================================================

  Future<bool> updateContact({
    required String id,
    required String name,
    required String phone,
    EmergencyContactType type =
        EmergencyContactType.personal,
    String? relationship,
    String? email,
    String? speciality,
    String? address,
    bool isPrimary = false,
  }) async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage =
          'User is not logged in.';

      notifyListeners();

      return false;
    }

    final index =
        _contacts.indexWhere(
      (contact) => contact.id == id,
    );

    if (index == -1) {
      return false;
    }

    try {
      _errorMessage = null;

      // ========================================================
      // REMOVE OLD PRIMARY
      // ========================================================

      if (isPrimary) {
        for (var i = 0;
            i < _contacts.length;
            i++) {
          if (_contacts[i].isPrimary) {
            _contacts[i] =
                _contacts[i].copyWith(
              isPrimary: false,
            );
          }
        }
      }

      // ========================================================
      // CREATE UPDATED CONTACT
      // ========================================================

      final contact = EmergencyContact(
        id: id,

        name: name.trim(),

        phone: phone.trim(),

        type: type,

        relationship: _clean(
          relationship,
        ),

        email: _clean(
          email,
        ),

        speciality: _clean(
          speciality,
        ),

        address: _clean(
          address,
        ),

        isPrimary: isPrimary,
      );

      // ========================================================
      // FIRESTORE
      // ========================================================

      await _emergencyService.updateContact(
        userId: userId,
        contact: contact,
      );

      // ========================================================
      // LOCAL STATE
      // ========================================================

      _contacts[index] = contact;

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'EmergencyProvider update error: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _errorMessage =
          'Unable to update emergency contact.';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // DELETE CONTACT
  // ============================================================

  Future<bool> deleteContact(
    String id,
  ) async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage =
          'User is not logged in.';

      notifyListeners();

      return false;
    }

    try {
      _errorMessage = null;

      await _emergencyService.deleteContact(
        userId: userId,
        contactId: id,
      );

      _contacts.removeWhere(
        (contact) => contact.id == id,
      );

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'EmergencyProvider delete error: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _errorMessage =
          'Unable to delete emergency contact.';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // SET PRIMARY
  // ============================================================

  Future<bool> setPrimaryContact(
    String id,
  ) async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage =
          'User is not logged in.';

      notifyListeners();

      return false;
    }

    try {
      await _emergencyService.setPrimaryContact(
        userId: userId,
        contactId: id,
      );

      for (var i = 0;
          i < _contacts.length;
          i++) {
        _contacts[i] =
            _contacts[i].copyWith(
          isPrimary:
              _contacts[i].id == id,
        );
      }

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'EmergencyProvider primary error: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _errorMessage =
          'Unable to set primary contact.';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CLEAR CONTACTS FROM PROVIDER
  // ============================================================
  //
  // IMPORTANT:
  // This clears only local provider state.
  //
  // It does NOT delete Firestore data.
  //
  // Use this during logout.
  // ============================================================

  void clearLocalContacts() {
    _contacts.clear();

    _userId = null;

    _errorMessage = null;

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // DELETE ALL CONTACTS FROM FIRESTORE
  // ============================================================

  Future<bool> clearContacts() async {
    final userId = _userId;

    if (userId == null) {
      _errorMessage =
          'User is not logged in.';

      notifyListeners();

      return false;
    }

    try {
      await _emergencyService
          .deleteAllContacts(
        userId: userId,
      );

      _contacts.clear();

      notifyListeners();

      return true;
    } catch (e, stackTrace) {
      debugPrint(
        'EmergencyProvider clear error: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _errorMessage =
          'Unable to remove emergency contacts.';

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAN STRING
  // ============================================================

  static String? _clean(
    String? value,
  ) {
    final text =
        value?.trim() ?? '';

    return text.isEmpty
        ? null
        : text;
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