import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/blog_model.dart';

class BlogProvider extends ChangeNotifier {
  BlogProvider() {
    _initialize();
  }

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _savedBlogsKey =
      'gocare_saved_blogs';

  static const String _recentBlogsKey =
      'gocare_recent_blogs';

  static const String _viewCountsKey =
      'gocare_blog_view_counts';

  // ============================================================
  // BLOG DATA
  // ============================================================

  final List<BlogModel> _blogs = const [
    BlogModel(
      id: '1',
      title: 'What to do during a medical emergency?',
      description:
          'Learn the important steps you should take when someone needs immediate medical assistance.',
      category: 'Emergency',
      readTime: '4 min read',
      imageUrl: '',
      authorName: 'GoCare',
      authorRole: 'Health & Safety',
      publishedAt: '2026-01-01',
      content:
          'Medical emergencies require quick thinking and appropriate action. Stay calm, assess the situation, and seek professional emergency assistance when required.',
      tags: [
        'emergency',
        'medical emergency',
        'safety',
        'health',
      ],
      isFeatured: true,
    ),

    BlogModel(
      id: '2',
      title: '5 first aid steps everyone should know',
      description:
          'Simple first aid techniques that can help you respond confidently before professional help arrives.',
      category: 'First Aid',
      readTime: '5 min read',
      imageUrl: '',
      authorName: 'GoCare',
      authorRole: 'First Aid',
      publishedAt: '2026-01-05',
      content:
          'Basic first aid knowledge can help you respond appropriately while waiting for professional medical assistance.',
      tags: [
        'first aid',
        'safety',
        'emergency',
        'basic first aid',
      ],
    ),

    BlogModel(
      id: '3',
      title: 'How to prepare for an emergency',
      description:
          'Build an emergency plan and keep important information ready when you need it most.',
      category: 'Safety',
      readTime: '6 min read',
      imageUrl: '',
      authorName: 'GoCare',
      authorRole: 'Health & Safety',
      publishedAt: '2026-01-10',
      content:
          'An emergency plan can help you and your family respond more effectively when an unexpected situation occurs.',
      tags: [
        'emergency planning',
        'safety',
        'family safety',
        'preparedness',
      ],
    ),

    BlogModel(
      id: '4',
      title: 'Finding healthcare near you',
      description:
          'Learn how to quickly find hospitals, clinics and pharmacies when healthcare is needed.',
      category: 'Healthcare',
      readTime: '3 min read',
      imageUrl: '',
      authorName: 'GoCare',
      authorRole: 'Healthcare',
      publishedAt: '2026-01-15',
      content:
          'Knowing how to find nearby healthcare facilities can be useful when medical assistance is required.',
      tags: [
        'healthcare',
        'hospital',
        'clinic',
        'pharmacy',
      ],
    ),
  ];

  // ============================================================
  // USER STATE
  // ============================================================

  final Set<String> _savedIds = <String>{};

  final List<String> _recentIds = <String>[];

  final Map<String, int> _viewCounts =
      <String, int>{};

  // ============================================================
  // SEARCH
  // ============================================================

  String _searchQuery = '';

  // ============================================================
  // INITIALIZATION
  // ============================================================

  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> _initialize() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      // ----------------------------------------------------------
      // SAVED BLOGS
      // ----------------------------------------------------------

      final saved =
          preferences.getStringList(
        _savedBlogsKey,
      );

      if (saved != null) {
        _savedIds
          ..clear()
          ..addAll(saved);
      }

      // ----------------------------------------------------------
      // RECENT BLOGS
      // ----------------------------------------------------------

      final recent =
          preferences.getStringList(
        _recentBlogsKey,
      );

      if (recent != null) {
        _recentIds
          ..clear()
          ..addAll(recent);
      }

      // ----------------------------------------------------------
      // VIEW COUNTS
      // ----------------------------------------------------------

      final counts =
          preferences.getStringList(
        _viewCountsKey,
      );

      if (counts != null) {
        _viewCounts.clear();

        for (final entry in counts) {
          final parts = entry.split('|');

          if (parts.length != 2) {
            continue;
          }

          final id = parts[0];
          final count = int.tryParse(parts[1]);

          if (count == null) {
            continue;
          }

          _viewCounts[id] = count;
        }
      }
    } catch (_) {
      // Keep the provider usable even if local storage
      // cannot be read.
    }

    _initialized = true;

    notifyListeners();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<BlogModel> get blogs =>
      List.unmodifiable(_blogs);

  // ============================================================
  // SEARCH QUERY
  // ============================================================

  String get searchQuery => _searchQuery;

  void setSearchQuery(String value) {
    final query = value.trim();

    if (_searchQuery == query) {
      return;
    }

    _searchQuery = query;

    notifyListeners();
  }

  void clearSearch() {
    if (_searchQuery.isEmpty) {
      return;
    }

    _searchQuery = '';

    notifyListeners();
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  List<String> get categories {
    return _blogs
        .map(
          (blog) => blog.category.trim(),
        )
        .where(
          (category) => category.isNotEmpty,
        )
        .toSet()
        .toList();
  }

  List<BlogModel> byCategory(
    String category,
  ) {
    return _blogs
        .where(
          (blog) =>
              blog.category.toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();
  }

  // ============================================================
  // FIND BLOG
  // ============================================================

  BlogModel? findById(String id) {
    for (final blog in _blogs) {
      if (blog.id == id) {
        return blog;
      }
    }

    return null;
  }

  // ============================================================
  // SEARCH BLOGS
  // ============================================================

  List<BlogModel> searchBlogs(
    String query,
  ) {
    final search =
        query.trim().toLowerCase();

    if (search.isEmpty) {
      return blogs;
    }

    return _blogs.where((blog) {
      final title =
          blog.title.toLowerCase();

      final description =
          blog.description.toLowerCase();

      final category =
          blog.category.toLowerCase();

      final author =
          blog.authorName.toLowerCase();

      final role =
          blog.authorRole.toLowerCase();

      final content =
          blog.content.toLowerCase();

      final tags = blog.tags.any(
        (tag) => tag
            .toLowerCase()
            .contains(search),
      );

      return title.contains(search) ||
          description.contains(search) ||
          category.contains(search) ||
          author.contains(search) ||
          role.contains(search) ||
          content.contains(search) ||
          tags;
    }).toList();
  }

  // ============================================================
  // SAVED BLOGS
  // ============================================================

  List<BlogModel> get savedItems {
    return _blogs
        .where(
          (blog) => _savedIds.contains(blog.id),
        )
        .toList();
  }

  bool isSaved(String blogId) {
    return _savedIds.contains(blogId);
  }

  Future<void> toggleSaved(
    String blogId,
  ) async {
    if (!_containsBlog(blogId)) {
      return;
    }

    if (_savedIds.contains(blogId)) {
      _savedIds.remove(blogId);
    } else {
      _savedIds.add(blogId);
    }

    notifyListeners();

    await _saveLocalData();
  }

  // ============================================================
  // RECENTLY VIEWED
  // ============================================================

  List<BlogModel> get recentItems {
    final result = <BlogModel>[];

    for (final id in _recentIds) {
      final blog = findById(id);

      if (blog != null) {
        result.add(blog);
      }
    }

    return result;
  }

  void recordView(
    String blogId,
  ) {
    if (!_containsBlog(blogId)) {
      return;
    }

    // ----------------------------------------------------------
    // RECENTLY VIEWED
    // ----------------------------------------------------------

    _recentIds.remove(blogId);
    _recentIds.insert(0, blogId);

    // Keep only the latest 10.
    if (_recentIds.length > 10) {
      _recentIds.removeRange(
        10,
        _recentIds.length,
      );
    }

    // ----------------------------------------------------------
    // VIEW COUNT
    // ----------------------------------------------------------

    _viewCounts[blogId] =
        (_viewCounts[blogId] ?? 0) + 1;

    notifyListeners();

    _saveLocalData();
  }

  Future<void> clearRecentlyViewed() async {
    if (_recentIds.isEmpty) {
      return;
    }

    _recentIds.clear();

    notifyListeners();

    await _saveLocalData();
  }

  // ============================================================
  // VIEW COUNT
  // ============================================================

  int viewCount(
    String blogId,
  ) {
    return _viewCounts[blogId] ?? 0;
  }

  // ============================================================
  // TOP VIEWED
  // ============================================================

  List<BlogModel> get topViewedItems {
    final viewedBlogs = _blogs
        .where(
          (blog) =>
              (_viewCounts[blog.id] ?? 0) > 0,
        )
        .toList();

    viewedBlogs.sort(
      (a, b) {
        final aViews =
            _viewCounts[a.id] ?? 0;

        final bViews =
            _viewCounts[b.id] ?? 0;

        return bViews.compareTo(aViews);
      },
    );

    return viewedBlogs
        .take(5)
        .toList();
  }

  // ============================================================
  // FEATURED BLOGS
  // ============================================================

  List<BlogModel> get featuredBlogs {
    return _blogs
        .where(
          (blog) => blog.isFeatured,
        )
        .toList();
  }

  // ============================================================
  // SPONSORED BLOGS
  // ============================================================

  List<BlogModel> get sponsoredBlogs {
    return _blogs
        .where(
          (blog) => blog.isSponsored,
        )
        .toList();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _containsBlog(
    String blogId,
  ) {
    return _blogs.any(
      (blog) => blog.id == blogId,
    );
  }

  // ============================================================
  // LOCAL STORAGE
  // ============================================================

  Future<void> _saveLocalData() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      await preferences.setStringList(
        _savedBlogsKey,
        _savedIds.toList(),
      );

      await preferences.setStringList(
        _recentBlogsKey,
        _recentIds,
      );

      final encodedViewCounts =
          _viewCounts.entries
              .map(
                (entry) =>
                    '${entry.key}|${entry.value}',
              )
              .toList();

      await preferences.setStringList(
        _viewCountsKey,
        encodedViewCounts,
      );
    } catch (_) {
      // Ignore local persistence errors.
    }
  }
}