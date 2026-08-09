import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _webClientId =
      '761218317880-tg9gr3ker575pjlfkcafvfo27g7ndp60.apps.googleusercontent.com';

  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ?? GoogleSignIn(serverClientId: _webClientId);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser {
    return _firebaseAuth.currentUser;
  }

  // ------------------------------------------------------------
  // EMAIL LOGIN
  // ------------------------------------------------------------

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ------------------------------------------------------------
  // REGISTER
  // ------------------------------------------------------------

  Future<UserCredential> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (displayName != null && displayName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(displayName.trim());
    }

    return credential;
  }

  // ------------------------------------------------------------
  // GOOGLE SIGN IN
  // ------------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD
  // ------------------------------------------------------------

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  // ------------------------------------------------------------
  // EMAIL VERIFICATION
  // ------------------------------------------------------------

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No authenticated user found.',
      );
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No authenticated user found.',
      );
    }

    await user.updateDisplayName(displayName?.trim());
    await user.updatePhotoURL(
      photoUrl == null || photoUrl.trim().isEmpty ? null : photoUrl.trim(),
    );
  }

  Future<void> updateEmail({required String email}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No authenticated user found.',
      );
    }

    await user.verifyBeforeUpdateEmail(email.trim());
  }

  Future<void> updatePassword({required String password}) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No authenticated user found.',
      );
    }

    await user.updatePassword(password);
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google logout errors.
    }

    await _firebaseAuth.signOut();
  }

  // ------------------------------------------------------------
  // REFRESH
  // ------------------------------------------------------------

  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }
}
