import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalEquipmentModel {
  const MedicalEquipmentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.brand,
    this.features = const [],
    this.usageInstructions = const [],
    this.considerations = const [],
    this.imageUrl,
    this.isFeatured = false,
    this.isSponsored = false,
    this.isActive = true,
    this.viewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  final String name;
  final String category;
  final String? brand;

  final String description;

  final List<String> features;

  final List<String> usageInstructions;

  final List<String> considerations;

  List<String> get uses => usageInstructions;
  List<String> get precautions => considerations;

  final String? imageUrl;

  final bool isFeatured;
  final bool isSponsored;
  final bool isActive;

  final int viewCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MedicalEquipmentModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MedicalEquipmentModel(
      id: id,

      name:
          map['name']?.toString() ?? '',

      category:
          map['category']?.toString() ?? '',

      brand:
          _nullableString(map['brand']),

      description:
          map['description']?.toString() ?? '',

      features:
          _stringList(map['features']),

      usageInstructions:
          _stringList(
        map['usageInstructions'],
      ),

      considerations:
          _stringList(
        map['considerations'],
      ),

      imageUrl:
          _nullableString(
        map['imageUrl'],
      ),

      isFeatured:
          map['isFeatured'] == true,

      isSponsored:
          map['isSponsored'] == true,

      isActive:
          map['isActive'] != false,

      viewCount:
          (map['viewCount'] as num?)
                  ?.toInt() ??
              0,

      createdAt:
          _parseDate(
        map['createdAt'],
      ),

      updatedAt:
          _parseDate(
        map['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),

      'category': category.trim(),

      'brand': brand,

      'description':
          description.trim(),

      'features': features,

      'usageInstructions':
          usageInstructions,

      'considerations':
          considerations,

      'imageUrl': imageUrl,

      'isFeatured':
          isFeatured,

      'isSponsored':
          isSponsored,

      'isActive':
          isActive,

      'viewCount':
          viewCount,

      'createdAt':
          createdAt,

      'updatedAt':
          updatedAt,
    };
  }

  MedicalEquipmentModel copyWith({
    String? name,
    String? category,
    String? brand,
    String? description,
    List<String>? features,
    List<String>? usageInstructions,
    List<String>? considerations,
    String? imageUrl,
    bool? isFeatured,
    bool? isSponsored,
    bool? isActive,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalEquipmentModel(
      id: id,

      name: name ?? this.name,

      category:
          category ?? this.category,

      brand:
          brand ?? this.brand,

      description:
          description ?? this.description,

      features:
          features ?? this.features,

      usageInstructions:
          usageInstructions ??
              this.usageInstructions,

      considerations:
          considerations ??
              this.considerations,

      imageUrl:
          imageUrl ?? this.imageUrl,

      isFeatured:
          isFeatured ??
              this.isFeatured,

      isSponsored:
          isSponsored ??
              this.isSponsored,

      isActive:
          isActive ??
              this.isActive,

      viewCount:
          viewCount ??
              this.viewCount,

      createdAt:
          createdAt ??
              this.createdAt,

      updatedAt:
          updatedAt ??
              this.updatedAt,
    );
  }

  static List<String> _stringList(
    dynamic value,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .map(
          (item) =>
              item.toString().trim(),
        )
        .where(
          (item) =>
              item.isNotEmpty,
        )
        .toList();
  }

  static String? _nullableString(
    dynamic value,
  ) {
    final text =
        value?.toString().trim() ??
            '';

    return text.isEmpty
        ? null
        : text;
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
      return DateTime.tryParse(
        value,
      );
    }

    return null;
  }
}