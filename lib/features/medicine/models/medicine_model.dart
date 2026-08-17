import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineModel {
  const MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.description,
    this.uses = const [],
    this.precautions = const [],
    this.sideEffects = const [],
    this.interactions = const [],
    this.storage,
    this.howItWorks,
    this.imageUrl,
    this.isFeatured = false,
    this.isActive = true,
    this.viewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  final String name;
  final String genericName;
  final String category;

  final String description;

  final List<String> uses;
  final List<String> precautions;
  final List<String> sideEffects;
  final List<String> interactions;

  final String? storage;
  final String? howItWorks;

  final String? imageUrl;

  final bool isFeatured;
  final bool isActive;

  final int viewCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MedicineModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MedicineModel(
      id: id,
      name: map['name']?.toString() ?? '',
      genericName:
          map['genericName']?.toString() ?? '',
      category:
          map['category']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      uses: _stringList(map['uses']),
      precautions:
          _stringList(map['precautions']),
      sideEffects:
          _stringList(map['sideEffects']),
      interactions:
          _stringList(map['interactions']),
      storage:
          _nullableString(map['storage']),
      howItWorks:
          _nullableString(map['howItWorks']),
      imageUrl:
          _nullableString(map['imageUrl']),
      isFeatured:
          map['isFeatured'] == true,
      isActive:
          map['isActive'] != false,
      viewCount:
          (map['viewCount'] as num?)?.toInt() ?? 0,
      createdAt:
          _parseDate(map['createdAt']),
      updatedAt:
          _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'genericName': genericName.trim(),
      'category': category.trim(),
      'description': description.trim(),

      'uses': uses,
      'precautions': precautions,
      'sideEffects': sideEffects,
      'interactions': interactions,

      'storage': storage,
      'howItWorks': howItWorks,

      'imageUrl': imageUrl,

      'isFeatured': isFeatured,
      'isActive': isActive,

      'viewCount': viewCount,

      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  MedicineModel copyWith({
    String? name,
    String? genericName,
    String? category,
    String? description,
    List<String>? uses,
    List<String>? precautions,
    List<String>? sideEffects,
    List<String>? interactions,
    String? storage,
    String? howItWorks,
    String? imageUrl,
    bool? isFeatured,
    bool? isActive,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineModel(
      id: id,
      name: name ?? this.name,
      genericName:
          genericName ?? this.genericName,
      category:
          category ?? this.category,
      description:
          description ?? this.description,
      uses: uses ?? this.uses,
      precautions:
          precautions ?? this.precautions,
      sideEffects:
          sideEffects ?? this.sideEffects,
      interactions:
          interactions ?? this.interactions,
      storage: storage ?? this.storage,
      howItWorks:
          howItWorks ?? this.howItWorks,
      imageUrl:
          imageUrl ?? this.imageUrl,
      isFeatured:
          isFeatured ?? this.isFeatured,
      isActive:
          isActive ?? this.isActive,
      viewCount:
          viewCount ?? this.viewCount,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
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
          (item) => item.toString().trim(),
        )
        .where(
          (item) => item.isNotEmpty,
        )
        .toList();
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