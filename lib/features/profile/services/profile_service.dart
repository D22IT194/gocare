import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/health_information.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }

  // ============================================================
  // SAVE HEALTH INFORMATION
  // ============================================================

  Future<void> saveHealthInformation({
    required String userId,
    required HealthInformation healthInformation,
  }) async {
    await _usersCollection.doc(userId).set({
      'healthInformation': healthInformation.toMap(),

      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ============================================================
  // GET HEALTH INFORMATION
  // ============================================================

  Future<HealthInformation?> getHealthInformation({
    required String userId,
  }) async {
    final snapshot = await _usersCollection.doc(userId).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    final healthData = data['healthInformation'];

    if (healthData is! Map) {
      return null;
    }

    return HealthInformation.fromMap(Map<String, dynamic>.from(healthData));
  }

  Future<void> saveProfileDetails({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    String? photoUrl,
  }) async {
    await _usersCollection.doc(userId).set({
      'profile': {
        'name': name.trim(),
        'email': email.trim(),
        'phoneNumber': phoneNumber.trim(),
        'photoUrl': photoUrl?.trim(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProfileDetails({
    required String userId,
  }) async {
    final snapshot = await _usersCollection.doc(userId).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    final profileData = data?['profile'];

    if (profileData is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(profileData);
  }
}
