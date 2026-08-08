class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool emailVerified;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.emailVerified = false,
  });

  factory AppUser.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    bool emailVerified = false,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      emailVerified: emailVerified,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    bool? emailVerified,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  String toString() {
    return 'AppUser('
        'uid: $uid, '
        'email: $email, '
        'displayName: $displayName, '
        'phoneNumber: $phoneNumber, '
        'emailVerified: $emailVerified'
        ')';
  }
}