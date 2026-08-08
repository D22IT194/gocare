import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    AuthService? authService,
  }) : _authService = authService ?? AuthService() {
    _initialize();
  }

  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  AppUser? _user;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  AuthStatus get status => _status;

  AppUser? get user => _user;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;

  Future<void> _initialize() async {
    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChanged,
      onError: (Object error) {
        _setError(
          _firebaseErrorMessage(error),
        );
      },
    );
  }

  void _handleAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
    } else {
      _user = _mapFirebaseUser(firebaseUser);
      _status = AuthStatus.authenticated;
    }

    _errorMessage = null;
    notifyListeners();
  }

  AppUser _mapFirebaseUser(User user) {
    return AppUser.fromFirebaseUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      return true;
    } on FirebaseAuthException catch (error) {
      _setError(_firebaseErrorMessage(error));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading();

    try {
      await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      return true;
    } on FirebaseAuthException catch (error) {
      _setError(_firebaseErrorMessage(error));
      return false;
    } catch (_) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> forgotPassword({
    required String email,
  }) async {
    _setLoading();

    try {
      await _authService.sendPasswordResetEmail(
        email: email,
      );

      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (error) {
      _setError(_firebaseErrorMessage(error));
      return false;
    } catch (_) {
      _setError('Unable to send reset email. Please try again.');
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } on FirebaseAuthException catch (error) {
      _setError(_firebaseErrorMessage(error));
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading();

    try {
      await _authService.logout();
    } catch (_) {
      _setError('Unable to logout. Please try again.');
    }
  }

  Future<void> refreshUser() async {
    try {
      await _authService.reloadUser();

      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        _user = _mapFirebaseUser(firebaseUser);
        notifyListeners();
      }
    } catch (_) {
      // Keep the current state if refreshing fails.
    }
  }

  void clearError() {
    _errorMessage = null;

    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _firebaseErrorMessage(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Something went wrong. Please try again.';
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password is too weak.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return error.message ??
            'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}