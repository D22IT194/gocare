import 'package:cloud_firestore/cloud_firestore.dart';

enum AffiliateProductType {
  medicine,
  medicalEquipment,
}

extension AffiliateProductTypeExtension
    on AffiliateProductType {
  String get value {
    switch (this) {
      case AffiliateProductType.medicine:
        return 'medicine';

      case AffiliateProductType.medicalEquipment:
        return 'medicalEquipment';
    }
  }

  String get label {
    switch (this) {
      case AffiliateProductType.medicine:
        return 'Medicine';

      case AffiliateProductType.medicalEquipment:
        return 'Medical Equipment';
    }
  }
}

class AffiliateProductModel {
  const AffiliateProductModel({
    required this.id,
    required this.title,
    required this.type,
    required this.affiliateUrl,
    this.medicineId,
    this.equipmentId,
    this.description,
    this.imageUrl,
    this.merchant,
    this.price,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    this.isFeatured = false,
    this.isSponsored = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  final String title;

  final AffiliateProductType type;

  final String affiliateUrl;

  /// Filled when the product belongs to a medicine.
  final String? medicineId;

  /// Filled when the product belongs to medical equipment.
  final String? equipmentId;

  final String? description;
  final String? imageUrl;

  final String? merchant;

  final double? price;
  final double? originalPrice;

  final double? rating;
  final int? reviewCount;

  final bool isFeatured;
  final bool isSponsored;
  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AffiliateProductModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AffiliateProductModel(
      id: id,
      title:
          map['title']?.toString() ?? '',
      type:
          _parseType(map['type']),
      affiliateUrl:
          map['affiliateUrl']?.toString() ?? '',

      medicineId:
          _nullableString(
        map['medicineId'],
      ),

      equipmentId:
          _nullableString(
        map['equipmentId'],
      ),

      description:
          _nullableString(
        map['description'],
      ),

      imageUrl:
          _nullableString(
        map['imageUrl'],
      ),

      merchant:
          _nullableString(
        map['merchant'],
      ),

      price:
          (map['price'] as num?)?.toDouble(),

      originalPrice:
          (map['originalPrice'] as num?)
              ?.toDouble(),

      rating:
          (map['rating'] as num?)?.toDouble(),

      reviewCount:
          (map['reviewCount'] as num?)?.toInt(),

      isFeatured:
          map['isFeatured'] == true,

      isSponsored:
          map['isSponsored'] == true,

      isActive:
          map['isActive'] != false,

      createdAt:
          _parseDate(map['createdAt']),

      updatedAt:
          _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title.trim(),

      'type': type.value,

      'affiliateUrl':
          affiliateUrl.trim(),

      'medicineId': medicineId,
      'equipmentId': equipmentId,

      'description': description,
      'imageUrl': imageUrl,

      'merchant': merchant,

      'price': price,
      'originalPrice': originalPrice,

      'rating': rating,
      'reviewCount': reviewCount,

      'isFeatured': isFeatured,
      'isSponsored': isSponsored,
      'isActive': isActive,

      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AffiliateProductModel copyWith({
    String? title,
    AffiliateProductType? type,
    String? affiliateUrl,
    String? medicineId,
    String? equipmentId,
    String? description,
    String? imageUrl,
    String? merchant,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isSponsored,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AffiliateProductModel(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      affiliateUrl:
          affiliateUrl ?? this.affiliateUrl,
      medicineId:
          medicineId ?? this.medicineId,
      equipmentId:
          equipmentId ?? this.equipmentId,
      description:
          description ?? this.description,
      imageUrl:
          imageUrl ?? this.imageUrl,
      merchant:
          merchant ?? this.merchant,
      price:
          price ?? this.price,
      originalPrice:
          originalPrice ??
              this.originalPrice,
      rating:
          rating ?? this.rating,
      reviewCount:
          reviewCount ?? this.reviewCount,
      isFeatured:
          isFeatured ?? this.isFeatured,
      isSponsored:
          isSponsored ?? this.isSponsored,
      isActive:
          isActive ?? this.isActive,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  static AffiliateProductType _parseType(
    dynamic value,
  ) {
    final type =
        value?.toString();

    return AffiliateProductType.values
        .firstWhere(
      (item) => item.value == type,
      orElse: () =>
          AffiliateProductType
              .medicalEquipment,
    );
  }

  static String? _nullableString(
    dynamic value,
  ) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}