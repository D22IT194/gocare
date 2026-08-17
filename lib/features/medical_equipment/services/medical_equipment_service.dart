import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/medical_equipment_model.dart';
import '../models/equipment_category_model.dart';
import '../models/affiliate_product_model.dart';

class MedicalEquipmentService {
  MedicalEquipmentService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ============================================================
  // COLLECTIONS
  // ============================================================

  CollectionReference<Map<String, dynamic>>
      get _equipmentCollection {
    return _firestore.collection(
      'medicalEquipment',
    );
  }

  CollectionReference<Map<String, dynamic>>
      get _categoriesCollection {
    return _firestore.collection(
      'medicalEquipmentCategories',
    );
  }

  CollectionReference<Map<String, dynamic>>
      get _affiliateProductsCollection {
    return _firestore.collection(
      'affiliateProducts',
    );
  }

  // ============================================================
  // GET ALL ACTIVE EQUIPMENT
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getEquipment() async {
    final snapshot =
        await _equipmentCollection
            .where(
              'isActive',
              isEqualTo: true,
            )
            .get();

    final equipment =
        snapshot.docs.map((document) {
      return MedicalEquipmentModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();

    equipment.sort(
      (a, b) => a.name
          .toLowerCase()
          .compareTo(
            b.name.toLowerCase(),
          ),
    );

    return equipment;
  }

  // ============================================================
  // GET EQUIPMENT BY ID
  // ============================================================

  Future<MedicalEquipmentModel?>
      getEquipmentById(
    String equipmentId,
  ) async {
    final document =
        await _equipmentCollection
            .doc(equipmentId)
            .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return MedicalEquipmentModel.fromMap(
      document.id,
      data,
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      searchEquipment(
    String query,
  ) async {
    final equipment =
        await getEquipment();

    final normalizedQuery =
        query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return equipment;
    }

    return equipment.where((item) {
      return item.name
              .toLowerCase()
              .contains(normalizedQuery) ||
          item.category
              .toLowerCase()
              .contains(normalizedQuery) ||
          item.description
              .toLowerCase()
              .contains(normalizedQuery) ||
          item.features.any(
            (feature) => feature
                .toLowerCase()
                .contains(
                  normalizedQuery,
                ),
          );
    }).toList();
  }

  // ============================================================
  // GET BY CATEGORY
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getEquipmentByCategory(
    String category,
  ) async {
    final snapshot =
        await _equipmentCollection
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
      return MedicalEquipmentModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // FEATURED
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getFeaturedEquipment({
    int limit = 10,
  }) async {
    final snapshot =
        await _equipmentCollection
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
      return MedicalEquipmentModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // SPONSORED
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getSponsoredEquipment({
    int limit = 10,
  }) async {
    final snapshot =
        await _equipmentCollection
            .where(
              'isActive',
              isEqualTo: true,
            )
            .where(
              'isSponsored',
              isEqualTo: true,
            )
            .limit(limit)
            .get();

    return snapshot.docs.map((document) {
      return MedicalEquipmentModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // POPULAR
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getPopularEquipment({
    int limit = 10,
  }) async {
    final snapshot =
        await _equipmentCollection
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
      return MedicalEquipmentModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Future<List<EquipmentCategoryModel>>
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
      return EquipmentCategoryModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // INCREMENT VIEW COUNT
  // ============================================================

  Future<void> incrementViewCount(
    String equipmentId,
  ) async {
    await _equipmentCollection
        .doc(equipmentId)
        .update({
      'viewCount':
          FieldValue.increment(1),
    });
  }

  // ============================================================
  // RECENTLY VIEWED
  // ============================================================

  Future<void> addRecentlyViewed({
    required String userId,
    required String equipmentId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(
          'recentlyViewedEquipment',
        )
        .doc(equipmentId)
        .set({
      'equipmentId': equipmentId,
      'viewedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // GET RECENTLY VIEWED
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getRecentlyViewed({
    required String userId,
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection(
          'recentlyViewedEquipment',
        )
        .orderBy(
          'viewedAt',
          descending: true,
        )
        .limit(limit)
        .get();

    final results =
        <MedicalEquipmentModel>[];

    for (final document
        in snapshot.docs) {
      final equipmentId =
          document.data()['equipmentId']
              ?.toString();

      if (equipmentId == null ||
          equipmentId.isEmpty) {
        continue;
      }

      final equipment =
          await getEquipmentById(
        equipmentId,
      );

      if (equipment != null) {
        results.add(equipment);
      }
    }

    return results;
  }

  // ============================================================
  // SAVED EQUIPMENT
  // ============================================================

  Future<void> saveEquipment({
    required String userId,
    required String equipmentId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedMedicalEquipment')
        .doc(equipmentId)
        .set({
      'equipmentId': equipmentId,
      'savedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REMOVE SAVED EQUIPMENT
  // ============================================================

  Future<void> removeSavedEquipment({
    required String userId,
    required String equipmentId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savedMedicalEquipment')
        .doc(equipmentId)
        .delete();
  }

  // ============================================================
  // CHECK SAVED
  // ============================================================

  Future<bool> isEquipmentSaved({
    required String userId,
    required String equipmentId,
  }) async {
    final document =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection(
              'savedMedicalEquipment',
            )
            .doc(equipmentId)
            .get();

    return document.exists;
  }

  // ============================================================
  // GET SAVED EQUIPMENT
  // ============================================================

  Future<List<MedicalEquipmentModel>>
      getSavedEquipment({
    required String userId,
  }) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection(
              'savedMedicalEquipment',
            )
            .orderBy(
              'savedAt',
              descending: true,
            )
            .get();

    final results =
        <MedicalEquipmentModel>[];

    for (final document
        in snapshot.docs) {
      final equipmentId =
          document.data()['equipmentId']
              ?.toString();

      if (equipmentId == null ||
          equipmentId.isEmpty) {
        continue;
      }

      final equipment =
          await getEquipmentById(
        equipmentId,
      );

      if (equipment != null) {
        results.add(equipment);
      }
    }

    return results;
  }

  // ============================================================
  // AFFILIATE PRODUCTS
  // ============================================================

  Future<List<AffiliateProductModel>>
      getAffiliateProductsForEquipment(
    String equipmentId,
  ) async {
    final snapshot =
        await _affiliateProductsCollection
            .where(
              'type',
              isEqualTo: 'medicalEquipment',
            )
            .where(
              'equipmentId',
              isEqualTo: equipmentId,
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