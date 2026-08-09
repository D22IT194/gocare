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
}