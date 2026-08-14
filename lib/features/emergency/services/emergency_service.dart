import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/emergency_contact.dart';

class EmergencyService {
  EmergencyService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // USER EMERGENCY CONTACTS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> _contactsCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergencyContacts');
  }

  // ============================================================
  // GET CONTACTS
  // ============================================================

  Future<List<EmergencyContact>> getContacts({required String userId}) async {
    final snapshot = await _contactsCollection(userId).orderBy('name').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return EmergencyContact.fromMap({...data, 'id': data['id'] ?? doc.id});
    }).toList();
  }

  // ============================================================
  // GET SINGLE CONTACT
  // ============================================================

  Future<EmergencyContact?> getContact({
    required String userId,
    required String contactId,
  }) async {
    final doc = await _contactsCollection(userId).doc(contactId).get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return EmergencyContact.fromMap({...data, 'id': data['id'] ?? doc.id});
  }

  // ============================================================
  // ADD CONTACT
  // ============================================================

  Future<void> addContact({
    required String userId,
    required EmergencyContact contact,
  }) async {
    final collection = _contactsCollection(userId);

    // ----------------------------------------------------------
    // NORMAL CONTACT
    // ----------------------------------------------------------

    if (!contact.isPrimary) {
      await collection.doc(contact.id).set({
        ...contact.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return;
    }

    // ----------------------------------------------------------
    // PRIMARY CONTACT
    //
    // IMPORTANT:
    // Only remove primary status from contacts
    // having the SAME TYPE.
    //
    // Therefore:
    //
    // Personal primary
    // +
    // Doctor primary
    //
    // can exist at the same time.
    // ----------------------------------------------------------

    final snapshot = await collection.get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      final data = document.data();

      final existingType = data['type']?.toString();

      if (existingType == contact.type.name) {
        batch.update(document.reference, {
          'isPrimary': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    // ----------------------------------------------------------
    // ADD NEW CONTACT AS PRIMARY
    // ----------------------------------------------------------

    batch.set(collection.doc(contact.id), {
      ...contact.toMap(),
      'isPrimary': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ============================================================
  // UPDATE CONTACT
  // ============================================================

  Future<void> updateContact({
    required String userId,
    required EmergencyContact contact,
  }) async {
    final collection = _contactsCollection(userId);

    // ----------------------------------------------------------
    // NORMAL CONTACT
    // ----------------------------------------------------------

    if (!contact.isPrimary) {
      await collection.doc(contact.id).set({
        ...contact.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return;
    }

    // ----------------------------------------------------------
    // PRIMARY CONTACT
    //
    // Only contacts with the same type are affected.
    // ----------------------------------------------------------

    final snapshot = await collection.get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      final data = document.data();

      final existingType = data['type']?.toString();

      // Do not remove primary status from
      // another contact type.
      if (existingType == contact.type.name && document.id != contact.id) {
        batch.update(document.reference, {
          'isPrimary': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    // ----------------------------------------------------------
    // UPDATE SELECTED CONTACT
    // ----------------------------------------------------------

    batch.set(collection.doc(contact.id), {
      ...contact.toMap(),
      'isPrimary': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // ============================================================
  // DELETE CONTACT
  // ============================================================

  Future<void> deleteContact({
    required String userId,
    required String contactId,
  }) async {
    await _contactsCollection(userId).doc(contactId).delete();
  }

  // ============================================================
  // DELETE ALL CONTACTS
  // ============================================================

  Future<void> deleteAllContacts({required String userId}) async {
    final snapshot = await _contactsCollection(userId).get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }

  // ============================================================
  // SET PRIMARY CONTACT
  // ============================================================

  Future<void> setPrimaryContact({
    required String userId,
    required String contactId,
  }) async {
    final collection = _contactsCollection(userId);

    // ----------------------------------------------------------
    // FIRST GET SELECTED CONTACT
    // ----------------------------------------------------------

    final selectedDocument = await collection.doc(contactId).get();

    if (!selectedDocument.exists) {
      throw Exception('Emergency contact not found.');
    }

    final selectedData = selectedDocument.data();

    if (selectedData == null) {
      throw Exception('Emergency contact data not found.');
    }

    // ----------------------------------------------------------
    // GET SELECTED CONTACT TYPE
    // ----------------------------------------------------------

    final selectedType = selectedData['type']?.toString();

    if (selectedType == null || selectedType.isEmpty) {
      throw Exception('Emergency contact type is missing.');
    }

    // ----------------------------------------------------------
    // GET ALL CONTACTS
    // ----------------------------------------------------------

    final snapshot = await collection.get();

    final batch = _firestore.batch();

    // ----------------------------------------------------------
    // RESET PRIMARY ONLY FOR SAME TYPE
    // ----------------------------------------------------------

    for (final document in snapshot.docs) {
      final data = document.data();

      final contactType = data['type']?.toString();

      if (contactType == selectedType) {
        batch.update(document.reference, {
          'isPrimary': document.id == contactId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }
}
