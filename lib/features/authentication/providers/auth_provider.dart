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

  bool get isAuthenticated =>
      _status == AuthStatus.authenticated;

  bool get isUnauthenticated =>
      _status == AuthStatus.unauthenticated;

  Future<void> _initialize() async {
    try {
      _authSubscription = _authService.authStateChanges.listen(
        _handleAuthStateChanged,
        onError: (Object error) {
          debugPrint('Auth state error: $error');

          _status = AuthStatus.unauthenticated;
          _errorMessage = null;

          notifyListeners();
        },
      );
    } catch (error) {
      debugPrint('Auth initialization error: $error');

      _status = AuthStatus.unauthenticated;
      _errorMessage = null;

      notifyListeners();
    }
  }

  void _handleAuthStateChanged(User? firebaseUser) {
    debugPrint(
      'Auth state changed: ${firebaseUser?.email ?? 'SIGNED OUT'}',
    );

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

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      debugPrint('LOGIN START: ${email.trim()}');

      await _authService.login(
        email: email,
        password: password,
      );

      debugPrint('LOGIN SUCCESS');

      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        _user = _mapFirebaseUser(firebaseUser);
        _status = AuthStatus.authenticated;
        _errorMessage = null;

        notifyListeners();

        return true;
      }

      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Login failed. Please try again.';

      notifyListeners();

      return false;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'LOGIN FIREBASE ERROR: ${error.code} - ${error.message}',
      );

      _setError(_firebaseErrorMessage(error));

      return false;
    } catch (error, stackTrace) {
      debugPrint('LOGIN ERROR: $error');
      debugPrint('$stackTrace');

      _setError(
        'Something went wrong. Please try again.',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // REGISTER
  // ------------------------------------------------------------

  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading();

    try {
      debugPrint('REGISTER START: ${email.trim()}');

      final credential = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        _user = _mapFirebaseUser(firebaseUser);
        _status = AuthStatus.authenticated;
        _errorMessage = null;

        notifyListeners();

        return true;
      }

      _setError(
        'Unable to create your account.',
      );

      return false;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'REGISTER FIREBASE ERROR: ${error.code} - ${error.message}',
      );

      _setError(_firebaseErrorMessage(error));

      return false;
    } catch (error, stackTrace) {
      debugPrint('REGISTER ERROR: $error');
      debugPrint('$stackTrace');

      _setError(
        'Something went wrong. Please try again.',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // GOOGLE SIGN IN
  // ------------------------------------------------------------

  Future<bool> signInWithGoogle() async {
    _setLoading();

    try {
      debugPrint('GOOGLE SIGN-IN START');

      final credential =
          await _authService.signInWithGoogle();

      if (credential == null) {
        debugPrint('GOOGLE SIGN-IN CANCELLED');

        _status = _user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;

        _errorMessage = null;

        notifyListeners();

        return false;
      }

      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        _user = _mapFirebaseUser(firebaseUser);
        _status = AuthStatus.authenticated;
        _errorMessage = null;

        notifyListeners();

        debugPrint('GOOGLE SIGN-IN SUCCESS');

        return true;
      }

      _setError(
        'Google sign-in failed. Please try again.',
      );

      return false;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'GOOGLE FIREBASE ERROR: ${error.code} - ${error.message}',
      );

      _setError(_firebaseErrorMessage(error));

      return false;
    } catch (error, stackTrace) {
      debugPrint('GOOGLE SIGN-IN ERROR: $error');
      debugPrint('$stackTrace');

      _setError(
        'Google sign-in failed. Please try again.',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD
  // ------------------------------------------------------------

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
    } catch (error) {
      debugPrint('FORGOT PASSWORD ERROR: $error');

      _setError(
        'Unable to send reset email. Please try again.',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // EMAIL VERIFICATION
  // ------------------------------------------------------------

  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();

      return true;
    } on FirebaseAuthException catch (error) {
      _setError(_firebaseErrorMessage(error));

      return false;
    } catch (error) {
      debugPrint('EMAIL VERIFICATION ERROR: $error');

      _setError(
        'Unable to send verification email.',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<bool> logout() async {
    _setLoading();

    try {
      await _authService.logout();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (error) {
      debugPrint('LOGOUT ERROR: $error');

      _setError(
        'Unable to logout. Please try again.',
      );

      return false;
    }
  }

  // ------------------------------------------------------------
  // REFRESH USER
  // ------------------------------------------------------------

  Future<void> refreshUser() async {
    try {
      await _authService.reloadUser();

      final firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        _user = _mapFirebaseUser(firebaseUser);
        _status = AuthStatus.authenticated;

        notifyListeners();
      }
    } catch (error) {
      debugPrint('REFRESH USER ERROR: $error');
    }
  }

  // ------------------------------------------------------------
  // CLEAR ERROR
  // ------------------------------------------------------------

  void clearError() {
    _errorMessage = null;

    if (_status == AuthStatus.error) {
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // ------------------------------------------------------------
  // INTERNAL STATE
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // FIREBASE ERROR MESSAGES
  // ------------------------------------------------------------

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

      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in provider.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'requires-recent-login':
        return 'Please login again to continue.';

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