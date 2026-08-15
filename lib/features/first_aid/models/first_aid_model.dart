class FirstAidModel {
  const FirstAidModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.steps,
    required this.doNot,
    required this.whenToCallEmergency,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;

  final List<String> steps;
  final List<String> doNot;
  final String whenToCallEmergency;

  // ============================================================
  // FROM MAP
  // ============================================================

  factory FirstAidModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return FirstAidModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '🩹',
      category:
          map['category']?.toString() ?? 'General',

      steps: _stringList(
        map['steps'],
      ),

      doNot: _stringList(
        map['doNot'],
      ),

      whenToCallEmergency:
          map['whenToCallEmergency']
                  ?.toString() ??
              '',
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'steps': steps,
      'doNot': doNot,
      'whenToCallEmergency':
          whenToCallEmergency,
    };
  }

  // ============================================================
  // STRING LIST HELPER
  // ============================================================

  static List<String> _stringList(
    dynamic value,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .map(
          (item) => item.toString(),
        )
        .toList();
  }
}