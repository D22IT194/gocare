class MedicineCategoryModel {
  const MedicineCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.iconName,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;

  final String? description;
  final String? imageUrl;
  final String? iconName;

  final bool isActive;
  final int sortOrder;

  factory MedicineCategoryModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return MedicineCategoryModel(
      id: id,
      name: map['name']?.toString() ?? '',
      description:
          _nullableString(map['description']),
      imageUrl:
          _nullableString(map['imageUrl']),
      iconName:
          _nullableString(map['iconName']),
      isActive:
          map['isActive'] != false,
      sortOrder:
          (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'description': description,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  static String? _nullableString(
    dynamic value,
  ) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty ? null : text;
  }
}