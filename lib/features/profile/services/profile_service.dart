import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/health_information.dart';
import '../../emergency/models/emergency_contact.dart';

class ProfileService {
  ProfileService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // USERS COLLECTION
  // ============================================================

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
    await _usersCollection.doc(userId).set(
      {
        'healthInformation': healthInformation.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // GET HEALTH INFORMATION
  // ============================================================

  Future<HealthInformation?> getHealthInformation({
    required String userId,
  }) async {
    final snapshot =
        await _usersCollection.doc(userId).get();

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

    return HealthInformation.fromMap(
      Map<String, dynamic>.from(healthData),
    );
  }

  // ============================================================
  // SAVE PROFILE DETAILS
  // ============================================================

  Future<void> saveProfileDetails({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    String? photoUrl,
  }) async {
    await _usersCollection.doc(userId).set(
      {
        'profile': {
          'name': name.trim(),
          'email': email.trim(),
          'phoneNumber': phoneNumber.trim(),
          'photoUrl': photoUrl?.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // GET PROFILE DETAILS
  // ============================================================

  Future<Map<String, dynamic>?> getProfileDetails({
    required String userId,
  }) async {
    final snapshot =
        await _usersCollection.doc(userId).get();

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

  // ============================================================
  // EMERGENCY CONTACTS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      _emergencyContactsCollection(
    String userId,
  ) {
    return _usersCollection
        .doc(userId)
        .collection('emergencyContacts');
  }

  // ============================================================
  // ADD / SAVE EMERGENCY CONTACT
  // ============================================================

  Future<void> saveEmergencyContact({
    required String userId,
    required EmergencyContact contact,
  }) async {
    await _emergencyContactsCollection(userId)
        .doc(contact.id)
        .set(
      {
        ...contact.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // GET ALL EMERGENCY CONTACTS
  // ============================================================

  Future<List<EmergencyContact>>
      getEmergencyContacts({
    required String userId,
  }) async {
    final snapshot =
        await _emergencyContactsCollection(userId)
            .get();

    return snapshot.docs.map((document) {
      final data = document.data();

      // Make sure the Firestore document ID is preserved.
      data['id'] ??= document.id;

      return EmergencyContact.fromMap(data);
    }).toList();
  }

  // ============================================================
  // GET SINGLE EMERGENCY CONTACT
  // ============================================================

  Future<EmergencyContact?>
      getEmergencyContact({
    required String userId,
    required String contactId,
  }) async {
    final document =
        await _emergencyContactsCollection(userId)
            .doc(contactId)
            .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    data['id'] ??= document.id;

    return EmergencyContact.fromMap(data);
  }

  // ============================================================
  // DELETE EMERGENCY CONTACT
  // ============================================================

  Future<void> deleteEmergencyContact({
    required String userId,
    required String contactId,
  }) async {
    await _emergencyContactsCollection(userId)
        .doc(contactId)
        .delete();
  }

  // ============================================================
  // DELETE ALL EMERGENCY CONTACTS
  // ============================================================

  Future<void> deleteAllEmergencyContacts({
    required String userId,
  }) async {
    final snapshot =
        await _emergencyContactsCollection(userId)
            .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }
}