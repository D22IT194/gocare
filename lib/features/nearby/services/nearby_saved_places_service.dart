import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/nearby_place.dart';

class NearbySavedPlacesService {
  NearbySavedPlacesService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _auth =
            auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
  }

  // ==========================================================
  // SAVED PLACES COLLECTION
  // ==========================================================

  CollectionReference<Map<String, dynamic>>
      get _collection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('savedPlaces');
  }

  // ==========================================================
  // SAVE PLACE
  // ==========================================================

  Future<void> savePlace(
    NearbyPlace place,
  ) async {
    await _collection
        .doc(place.id)
        .set(
      place
          .copyWith(
            isFavorite: true,
          )
          .toMap(),
      SetOptions(
        merge: true,
      ),
    );
  }

  // ==========================================================
  // REMOVE PLACE
  // ==========================================================

  Future<void> removePlace(
    String placeId,
  ) async {
    await _collection
        .doc(placeId)
        .delete();
  }

  // ==========================================================
  // GET ALL SAVED PLACES
  // ==========================================================

  Future<List<NearbyPlace>>
      getSavedPlaces() async {
    final snapshot =
        await _collection.get();

    final places = snapshot.docs
        .map(
          (doc) {
            final data = doc.data();

            // Make sure the Firestore document ID
            // is always available even if the stored
            // map doesn't contain an id.
            data['id'] ??= doc.id;

            return NearbyPlace.fromMap(
              data,
            );
          },
        )
        .toList();

    // Sort locally instead of using Firestore
    // orderBy(). This avoids requiring a Firestore
    // index and also handles old documents safely.
    places.sort(
      (a, b) => a.name
          .toLowerCase()
          .compareTo(
            b.name.toLowerCase(),
          ),
    );

    return places;
  }

  // ==========================================================
  // CHECK IF SAVED
  // ==========================================================

  Future<bool> isSaved(
    String placeId,
  ) async {
    final doc =
        await _collection
            .doc(placeId)
            .get();

    return doc.exists;
  }

  // ==========================================================
  // CLEAR ALL SAVED PLACES
  // ==========================================================

  Future<void> clearAll() async {
    final snapshot =
        await _collection.get();

    final batch =
        _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}