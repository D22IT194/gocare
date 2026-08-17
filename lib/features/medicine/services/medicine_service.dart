import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medicine_model.dart';
import '../models/medicine_category_model.dart';
import '../../medical_equipment/models/affiliate_product_model.dart';

class MedicineService {
  MedicineService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // COLLECTIONS
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _medicinesCollection {
    return _firestore.collection('medicines');
  }

  CollectionReference<Map<String, dynamic>>
      get _categoriesCollection {
    return _firestore.collection('medicineCategories');
  }

  CollectionReference<Map<String, dynamic>>
      get _affiliateProductsCollection {
    return _firestore.collection('affiliateProducts');
  }

  // ============================================================
  // GET ALL ACTIVE MEDICINES
  // ============================================================

  Future<List<MedicineModel>> getMedicines() async {
    final snapshot = await _medicinesCollection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    final medicines = snapshot.docs.map((document) {
      return MedicineModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();

    medicines.sort(
      (a, b) => a.name
          .toLowerCase()
          .compareTo(
            b.name.toLowerCase(),
          ),
    );

    return medicines;
  }

  // ============================================================
  // GET MEDICINE BY ID
  // ============================================================

  Future<MedicineModel?> getMedicineById(
    String medicineId,
  ) async {
    final document =
        await _medicinesCollection
            .doc(medicineId)
            .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return MedicineModel.fromMap(
      document.id,
      data,
    );
  }

  // ============================================================
  // SEARCH MEDICINES
  // ============================================================

  Future<List<MedicineModel>> searchMedicines(
    String query,
  ) async {
    final medicines = await getMedicines();

    final normalizedQuery =
        query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return medicines;
    }

    return medicines.where((medicine) {
      return medicine.name
              .toLowerCase()
              .contains(normalizedQuery) ||
          medicine.genericName
              .toLowerCase()
              .contains(normalizedQuery) ||
          medicine.category
              .toLowerCase()
              .contains(normalizedQuery) ||
          medicine.description
              .toLowerCase()
              .contains(normalizedQuery);
    }).toList();
  }

  // ============================================================
  // GET MEDICINES BY CATEGORY
  // ============================================================

  Future<List<MedicineModel>>
      getMedicinesByCategory(
    String category,
  ) async {
    final snapshot = await _medicinesCollection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'category',
          isEqualTo: category,
        )
        .get();

    return snapshot.docs.map((document) {
      return MedicineModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // FEATURED MEDICINES
  // ============================================================

  Future<List<MedicineModel>>
      getFeaturedMedicines({
    int limit = 10,
  }) async {
    final snapshot = await _medicinesCollection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .where(
          'isFeatured',
          isEqualTo: true,
        )
        .limit(limit)
        .get();

    return snapshot.docs.map((document) {
      return MedicineModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // POPULAR MEDICINES
  // ============================================================

  Future<List<MedicineModel>>
      getPopularMedicines({
    int limit = 10,
  }) async {
    final snapshot = await _medicinesCollection
        .where(
          'isActive',
          isEqualTo: true,
        )
        .orderBy(
          'viewCount',
          descending: true,
        )
        .limit(limit)
        .get();

    return snapshot.docs.map((document) {
      return MedicineModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Future<List<MedicineCategoryModel>>
      getCategories() async {
    final snapshot =
        await _categoriesCollection
            .where(
              'isActive',
              isEqualTo: true,
            )
            .orderBy('sortOrder')
            .get();

    return snapshot.docs.map((document) {
      return MedicineCategoryModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // INCREMENT VIEW COUNT
  // ============================================================

  Future<void> incrementViewCount(
    String medicineId,
  ) async {
    await _medicinesCollection
        .doc(medicineId)
        .update({
      'viewCount':
          FieldValue.increment(1),
    });
  }

  // ============================================================
  // USER RECENTLY VIEWED
  // ============================================================

  Future<void> addRecentlyViewed({
    required String userId,
    required String medicineId,
  }) async {
    final reference = _firestore
        .collection('users')
        .doc(userId)
        .collection('recentlyViewedMedicines')
        .doc(medicineId);

    await reference.set({
      'medicineId': medicineId,
      'viewedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET RECENTLY VIEWED MEDICINES
  // ============================================================

  Future<List<MedicineModel>>
      getRecentlyViewed({
    required String userId,
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recentlyViewedMedicines')
        .orderBy(
          'viewedAt',
          descending: true,
        )
        .limit(limit)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    final medicineIds = snapshot.docs
        .map(
          (document) =>
              document.data()['medicineId']
                  ?.toString(),
        )
        .whereType<String>()
        .toList();

    final results =
        <MedicineModel>[];

    for (final id in medicineIds) {
      final medicine =
          await getMedicineById(id);

      if (medicine != null) {
        results.add(medicine);
      }
    }

    return results;
  }

  // ============================================================
  // SAVE MEDICINE
  // ============================================================

  Future<void> saveMedicine({
    required String userId,
    required String medicineId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedMedicines')
        .doc(medicineId)
        .set({
      'medicineId': medicineId,
      'savedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REMOVE SAVED MEDICINE
  // ============================================================

  Future<void> removeSavedMedicine({
    required String userId,
    required String medicineId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedMedicines')
        .doc(medicineId)
        .delete();
  }

  // ============================================================
  // CHECK SAVED
  // ============================================================

  Future<bool> isMedicineSaved({
    required String userId,
    required String medicineId,
  }) async {
    final document = await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedMedicines')
        .doc(medicineId)
        .get();

    return document.exists;
  }

  // ============================================================
  // GET SAVED MEDICINES
  // ============================================================

  Future<List<MedicineModel>>
      getSavedMedicines({
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedMedicines')
        .orderBy(
          'savedAt',
          descending: true,
        )
        .get();

    final results =
        <MedicineModel>[];

    for (final document in snapshot.docs) {
      final medicineId =
          document.data()['medicineId']
              ?.toString();

      if (medicineId == null ||
          medicineId.isEmpty) {
        continue;
      }

      final medicine =
          await getMedicineById(medicineId);

      if (medicine != null) {
        results.add(medicine);
      }
    }

    return results;
  }

  // ============================================================
  // GET AFFILIATE PRODUCTS FOR MEDICINE
  // ============================================================

  Future<List<AffiliateProductModel>>
      getAffiliateProductsForMedicine(
    String medicineId,
  ) async {
    final snapshot =
        await _affiliateProductsCollection
            .where(
              'type',
              isEqualTo: 'medicine',
            )
            .where(
              'medicineId',
              isEqualTo: medicineId,
            )
            .where(
              'isActive',
              isEqualTo: true,
            )
            .get();

    return snapshot.docs.map((document) {
      return AffiliateProductModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }
}