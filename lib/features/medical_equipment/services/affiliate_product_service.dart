import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/affiliate_product_model.dart';

class AffiliateProductService {
  AffiliateProductService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _productsCollection {
    return _firestore.collection(
      'affiliateProducts',
    );
  }

  CollectionReference<Map<String, dynamic>>
      get _clicksCollection {
    return _firestore.collection(
      'affiliateClicks',
    );
  }

  // ============================================================
  // GET ALL PRODUCTS
  // ============================================================

  Future<List<AffiliateProductModel>>
      getProducts() async {
    final snapshot =
        await _productsCollection
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

  // ============================================================
  // GET PRODUCT
  // ============================================================

  Future<AffiliateProductModel?>
      getProductById(
    String productId,
  ) async {
    final document =
        await _productsCollection
            .doc(productId)
            .get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return AffiliateProductModel.fromMap(
      document.id,
      data,
    );
  }

  // ============================================================
  // FEATURED
  // ============================================================

  Future<List<AffiliateProductModel>>
      getFeaturedProducts({
    AffiliateProductType? type,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query =
        _productsCollection
            .where(
              'isActive',
              isEqualTo: true,
            )
            .where(
              'isFeatured',
              isEqualTo: true,
            );

    if (type != null) {
      query = query.where(
        'type',
        isEqualTo: type.value,
      );
    }

    final snapshot =
        await query.limit(limit).get();

    return snapshot.docs.map((document) {
      return AffiliateProductModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // SPONSORED
  // ============================================================

  Future<List<AffiliateProductModel>>
      getSponsoredProducts({
    AffiliateProductType? type,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query =
        _productsCollection
            .where(
              'isActive',
              isEqualTo: true,
            )
            .where(
              'isSponsored',
              isEqualTo: true,
            );

    if (type != null) {
      query = query.where(
        'type',
        isEqualTo: type.value,
      );
    }

    final snapshot =
        await query.limit(limit).get();

    return snapshot.docs.map((document) {
      return AffiliateProductModel.fromMap(
        document.id,
        document.data(),
      );
    }).toList();
  }

  // ============================================================
  // MEDICINE PRODUCTS
  // ============================================================

  Future<List<AffiliateProductModel>>
      getMedicineProducts(
    String medicineId,
  ) async {
    final snapshot =
        await _productsCollection
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

  // ============================================================
  // EQUIPMENT PRODUCTS
  // ============================================================

  Future<List<AffiliateProductModel>>
      getEquipmentProducts(
    String equipmentId,
  ) async {
    final snapshot =
        await _productsCollection
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

  // ============================================================
  // OPEN AFFILIATE URL
  // ============================================================

  Future<bool> openAffiliateProduct({
    required AffiliateProductModel product,
    String? userId,
  }) async {
    final urlString =
        product.affiliateUrl.trim();

    if (urlString.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(urlString);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https')) {
      return false;
    }

    await trackAffiliateClick(
      productId: product.id,
      type: product.type,
      userId: userId,
      medicineId: product.medicineId,
      equipmentId: product.equipmentId,
      merchant: product.merchant,
    );

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  // ============================================================
  // TRACK CLICK
  // ============================================================

  Future<void> trackAffiliateClick({
    required String productId,
    required AffiliateProductType type,
    String? userId,
    String? medicineId,
    String? equipmentId,
    String? merchant,
  }) async {
    await _clicksCollection.add({
      'productId': productId,
      'productType': type.value,
      'userId': userId,
      'medicineId': medicineId,
      'equipmentId': equipmentId,
      'merchant': merchant,
      'clickedAt':
          FieldValue.serverTimestamp(),
    });
  }
}