import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/emergency_contact.dart';

class EmergencyService {
  EmergencyService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // USER EMERGENCY CONTACTS COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> _contactsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergencyContacts');
  }

  // ============================================================
  // GET CONTACTS
  // ============================================================

  Future<List<EmergencyContact>> getContacts({
    required String userId,
  }) async {
    final snapshot = await _contactsCollection(userId)
        .orderBy('name')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return EmergencyContact.fromMap({
        ...data,
        'id': data['id'] ?? doc.id,
      });
    }).toList();
  }

  // ============================================================
  // GET SINGLE CONTACT
  // ============================================================

  Future<EmergencyContact?> getContact({
    required String userId,
    required String contactId,
  }) async {
    final doc = await _contactsCollection(userId)
        .doc(contactId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return EmergencyContact.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }

  // ============================================================
  // ADD CONTACT
  // ============================================================

  Future<void> addContact({
    required String userId,
    required EmergencyContact contact,
  }) async {
    final collection = _contactsCollection(userId);

    // If this contact should be primary,
    // remove primary status from all existing contacts.
    if (contact.isPrimary) {
      final snapshot = await collection.get();

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        batch.update(
          document.reference,
          {
            'isPrimary': false,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      batch.set(
        collection.doc(contact.id),
        {
          ...contact.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      return;
    }

    await collection.doc(contact.id).set({
      ...contact.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE CONTACT
  // ============================================================

  Future<void> updateContact({
    required String userId,
    required EmergencyContact contact,
  }) async {
    final collection = _contactsCollection(userId);

    if (contact.isPrimary) {
      final snapshot = await collection.get();

      final batch = _firestore.batch();

      for (final document in snapshot.docs) {
        if (document.id != contact.id) {
          batch.update(
            document.reference,
            {
              'isPrimary': false,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
        }
      }

      batch.set(
        collection.doc(contact.id),
        {
          ...contact.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      return;
    }

    await collection.doc(contact.id).set(
      {
        ...contact.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // DELETE CONTACT
  // ============================================================

  Future<void> deleteContact({
    required String userId,
    required String contactId,
  }) async {
    await _contactsCollection(userId)
        .doc(contactId)
        .delete();
  }

  // ============================================================
  // DELETE ALL CONTACTS
  // ============================================================

  Future<void> deleteAllContacts({
    required String userId,
  }) async {
    final snapshot =
        await _contactsCollection(userId).get();

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

    final snapshot = await collection.get();

    final selectedDocument = snapshot.docs
        .where((doc) => doc.id == contactId)
        .firstOrNull;

    if (selectedDocument == null) {
      throw Exception(
        'Emergency contact not found.',
      );
    }

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.update(
        document.reference,
        {
          'isPrimary': document.id == contactId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }
}