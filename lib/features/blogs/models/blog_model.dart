class BlogModel {
  const BlogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.readTime,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String readTime;
}