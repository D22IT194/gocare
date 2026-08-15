class BlogModel {
  const BlogModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.readTime,
    required this.imageUrl,
    required this.authorName,
    required this.authorRole,
    required this.publishedAt,
    required this.content,
    required this.tags,
    this.isFeatured = false,
    this.isSponsored = false,
    this.videoUrl,
  });

  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  final String id;
  final String title;
  final String description;
  final String category;
  final String readTime;

  // ============================================================
  // MEDIA
  // ============================================================

  /// Main/hero image URL.
  final String imageUrl;

  /// Optional explanation video.
  final String? videoUrl;

  // ============================================================
  // AUTHOR
  // ============================================================

  final String authorName;
  final String authorRole;

  // ============================================================
  // PUBLISHING
  // ============================================================

  final String publishedAt;

  // ============================================================
  // CONTENT
  // ============================================================

  /// Full article content.
  ///
  /// For now this is a String. Later this can be replaced with
  /// structured rich content if required.
  final String content;

  /// Searchable/content tags.
  final List<String> tags;

  // ============================================================
  // BUSINESS / CONTENT FLAGS
  // ============================================================

  /// Used for featured articles.
  final bool isFeatured;

  /// Used for clearly labelled sponsored/promotional content.
  final bool isSponsored;
}