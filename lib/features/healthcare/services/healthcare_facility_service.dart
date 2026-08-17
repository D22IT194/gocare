import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/healthcare_facility_model.dart';

class HealthcareFacilityService {
  HealthcareFacilityService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // COLLECTION
  // ============================================================

  static const String collectionName =
      'healthcare_facilities';

  CollectionReference<Map<String, dynamic>>
      get _facilities {
    return _firestore.collection(
      collectionName,
    );
  }

  // ============================================================
  // GET ALL ACTIVE FACILITIES
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      getFacilities() async {
    final snapshot = await _facilities
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              HealthcareFacilityModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET FACILITY BY ID
  // ============================================================

  Future<HealthcareFacilityModel?>
      getFacilityById(
    String facilityId,
  ) async {
    final doc =
        await _facilities
            .doc(facilityId)
            .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null) {
      return null;
    }

    return HealthcareFacilityModel.fromMap(
      doc.id,
      data,
    );
  }

  // ============================================================
  // GET FACILITIES BY TYPE
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      getFacilitiesByType(
    String type,
  ) async {
    final snapshot = await _facilities
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'type',
          isEqualTo: type,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              HealthcareFacilityModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET EMERGENCY FACILITIES
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      getEmergencyFacilities() async {
    final snapshot = await _facilities
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isEmergencyAvailable',
          isEqualTo: true,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              HealthcareFacilityModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // SEARCH FACILITIES
  //
  // Firestore does not provide normal contains()
  // search. Therefore search is performed locally
  // after loading active facilities.
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      searchFacilities(
    String query,
  ) async {
    final facilities =
        await getFacilities();

    final search =
        query.trim().toLowerCase();

    if (search.isEmpty) {
      return facilities;
    }

    return facilities.where(
      (facility) {
        final name =
            facility.name.toLowerCase();

        final address =
            facility.address.toLowerCase();

        final city =
            facility.city.toLowerCase();

        final specialityMatch =
            facility.specialities.any(
          (speciality) =>
              speciality
                  .toLowerCase()
                  .contains(search),
        );

        return name.contains(search) ||
            address.contains(search) ||
            city.contains(search) ||
            specialityMatch;
      },
    ).toList();
  }

  // ============================================================
  // GET FACILITIES BY CITY
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      getFacilitiesByCity(
    String city,
  ) async {
    final snapshot = await _facilities
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'city',
          isEqualTo: city,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              HealthcareFacilityModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET FEATURED FACILITIES
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      getFeaturedFacilities() async {
    final snapshot = await _facilities
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isFeatured',
          isEqualTo: true,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              HealthcareFacilityModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET SPONSORED FACILITIES
  // ============================================================

  Future<List<HealthcareFacilityModel>>
      getSponsoredFacilities() async {
    final snapshot = await _facilities
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isSponsored',
          isEqualTo: true,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              HealthcareFacilityModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // CREATE FACILITY
  // ============================================================

  Future<String> createFacility(
    Map<String, dynamic> data,
  ) async {
    final doc =
        await _facilities.add({
      ...data,
      'isActive':
          data['isActive'] ?? true,
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ============================================================
  // UPDATE FACILITY
  // ============================================================

  Future<void> updateFacility(
    String facilityId,
    Map<String, dynamic> data,
  ) async {
    await _facilities
        .doc(facilityId)
        .update({
      ...data,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // SOFT DELETE FACILITY
  // ============================================================

  Future<void> deactivateFacility(
    String facilityId,
  ) async {
    await _facilities
        .doc(facilityId)
        .update({
      'isActive': false,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ACTIVATE FACILITY
  // ============================================================

  Future<void> activateFacility(
    String facilityId,
  ) async {
    await _facilities
        .doc(facilityId)
        .update({
      'isActive': true,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }
}