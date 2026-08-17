class SpecialityModel {
  const SpecialityModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String icon;
  final bool isActive;
  final int sortOrder;

  factory SpecialityModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SpecialityModel(
      id: id,
      name: map['name'] as String? ?? '',
      icon: map['icon'] as String? ?? 'medical_services',
      isActive:
          map['isActive'] as bool? ?? true,
      sortOrder:
          (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}