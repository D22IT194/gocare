import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/blog_model.dart';
import '../providers/blog_provider.dart';
import '../widgets/blog_card.dart';
import 'blog_detail_screen.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  // ============================================================
  // CATEGORY
  // ============================================================




  void _validateSelectedFilter(
  BlogProvider provider,
) {
  if (_selectedFilter == 'My Saved Blogs' &&
      provider.savedItems.isEmpty) {
    _selectedFilter = 'All';
    return;
  }

  if (_selectedFilter == 'Recently Viewed' &&
      provider.recentItems.isEmpty) {
    _selectedFilter = 'All';
    return;
  }

  if (_selectedFilter == 'Top Viewed' &&
      provider.topViewedItems.isEmpty) {
    _selectedFilter = 'All';
  }
}

  String _selectedFilter = 'All';

  // ============================================================
  // SEARCH
  // ============================================================

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlogProvider>();

    final filters = _buildFilters(provider);

      _validateSelectedFilter(provider);

    final blogs = _getVisibleBlogs(provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: const Text('Health Blogs'),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,


        actions: [
          // ----------------------------------------------------
          // SAVED BLOGS
          // ----------------------------------------------------
          if (provider.savedItems.isNotEmpty)
            IconButton(
              tooltip: 'Saved blogs',
              onPressed: () {
                setState(() {
                  _selectedFilter = 'My Saved Blogs';
                });
              },
              icon: Badge(
                isLabelVisible: provider.savedItems.isNotEmpty,
                label: Text('${provider.savedItems.length}'),
                child: const Icon(Icons.bookmark_border_rounded),
              ),
            ),

          const SizedBox(width: 6),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          // const Padding(
          //   padding: EdgeInsets.fromLTRB(
          //     20,
          //     20,
          //     20,
          //     4,
          //   ),
          //   child: Text(
          //     'Health & Wellness',
          //     style: TextStyle(
          //       fontSize: 24,
          //       fontWeight:
          //           FontWeight.w800,
          //       color:
          //           Color(0xFF172B4D),
          //     ),
          //   ),
          // ),

          // const Padding(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 20,
          //   ),
          //   child: Text(
          //     'Trusted health information, safety tips and useful guidance.',
          //     style: TextStyle(
          //       fontSize: 14,
          //       height: 1.5,
          //       color:
          //           Color(0xFF667085),
          //     ),
          //   ),
          // ),

          // const SizedBox(height: 16),

          // ====================================================
          // SEARCH
          // ====================================================
          _buildSearchBar(provider),

          const SizedBox(height: 16),

          // ====================================================
          // FILTERS
          // ====================================================
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];

                final selected = filter == _selectedFilter;

                return _FilterChip(
                  label: filter,
                  selected: selected,
                  count: _getFilterCount(provider, filter),
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // ====================================================
          // CONTENT HEADER
          // ====================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getSectionTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172B4D),
                    ),
                  ),
                ),

                // ----------------------------------------------
                // CLEAR RECENT
                // ----------------------------------------------
                if (_selectedFilter == 'Recently Viewed' &&
                    provider.recentItems.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _showClearRecentDialog(context, provider);
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // BLOG LIST
          // ====================================================
          Expanded(
            child: blogs.isEmpty
                ? _buildEmptyState(context, provider)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: blogs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final blog = blogs[index];

                      return BlogCard(
                        blog: blog,

                        isSaved: provider.isSaved(blog.id),

                        onSave: () {
                          _handleSave(context, provider, blog);
                        },

                        onTap: () {
                          _openBlog(context, provider, blog);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(BlogProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          provider.setSearchQuery(value);

          setState(() {});
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search health articles...',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF98A2B3)),

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF667085),
          ),

          suffixIcon: provider.searchQuery.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();

                    provider.clearSearch();

                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,

          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(vertical: 14),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAECF0)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAECF0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.4),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  List<String> _buildFilters(BlogProvider provider) {
    final filters = <String>['All', ...provider.categories];

    // ----------------------------------------------------------
    // SAVED
    // ----------------------------------------------------------

    if (provider.savedItems.isNotEmpty) {
      filters.add('My Saved Blogs');
    }

    // final provider = context.watch<BlogProvider>();

    // ----------------------------------------------------------
    // RECENT
    // ----------------------------------------------------------

    if (provider.recentItems.isNotEmpty) {
      filters.add('Recently Viewed');
    }

    // ----------------------------------------------------------
    // TOP VIEWED
    // ----------------------------------------------------------

    if (provider.topViewedItems.isNotEmpty) {
      filters.add('Top Viewed');
    }

    return filters;
  }

  // ============================================================
  // FILTER COUNT
  // ============================================================

  int? _getFilterCount(BlogProvider provider, String filter) {
    switch (filter) {
      case 'My Saved Blogs':
        return provider.savedItems.length;

      case 'Recently Viewed':
        return provider.recentItems.length;

      case 'Top Viewed':
        return provider.topViewedItems.length;

      case 'All':
        return provider.blogs.length;

      default:
        return provider.byCategory(filter).length;
    }
  }

  // ============================================================
  // VISIBLE BLOGS
  // ============================================================

  List<BlogModel> _getVisibleBlogs(BlogProvider provider) {
    final query = provider.searchQuery.trim();

    List<BlogModel> result;

    // ----------------------------------------------------------
    // SPECIAL FILTERS
    // ----------------------------------------------------------

    switch (_selectedFilter) {
      case 'My Saved Blogs':
        result = provider.savedItems;
        break;

      case 'Recently Viewed':
        result = provider.recentItems;
        break;

      case 'Top Viewed':
        result = provider.topViewedItems;
        break;

      case 'All':
        result = provider.blogs;
        break;

      default:
        result = provider.byCategory(_selectedFilter);
    }

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    if (query.isEmpty) {
      return result;
    }

    final searchResults = provider.searchBlogs(query);

    final resultIds = result.map((blog) => blog.id);

    return searchResults.where((blog) => resultIds.contains(blog.id)).toList();
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  String _getSectionTitle() {
    switch (_selectedFilter) {
      case 'My Saved Blogs':
        return 'My Saved Blogs';

      case 'Recently Viewed':
        return 'Recently Viewed';

      case 'Top Viewed':
        return 'Top Viewed Blogs';

      case 'All':
        return 'Latest Articles';

      default:
        return _selectedFilter;
    }
  }

  // ============================================================
  // OPEN BLOG
  // ============================================================

  void _openBlog(BuildContext context, BlogProvider provider, BlogModel blog) {
    // Record view before opening.
    provider.recordView(blog.id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog)),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

Future<void> _handleSave(
  BuildContext context,
  BlogProvider provider,
  BlogModel blog,
) async {
  final bool isSaved = provider.isSaved(blog.id);

  // Remember whether this is the LAST saved blog.
  final bool isLastSavedBlog =
      isSaved && provider.savedItems.length == 1;

  // ============================================================
  // REMOVE CONFIRMATION
  // ============================================================

  if (isSaved) {
    final confirmed = await _showRemoveSavedDialog(
      context,
      blog,
    );

    if (confirmed != true) {
      return;
    }
  }

  // ============================================================
  // TOGGLE SAVE
  // ============================================================

  await provider.toggleSaved(blog.id);

  if (!mounted) {
    return;
  }

  // ============================================================
  // LAST SAVED BLOG REMOVED
  // ============================================================

  if (isLastSavedBlog &&
      _selectedFilter == 'My Saved Blogs') {
    setState(() {
      _selectedFilter = 'All';
    });
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  ScaffoldMessenger.of(context)
      .hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        isSaved
            ? 'Removed from saved blogs'
            : 'Saved to My Saved Blogs',
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
  // ============================================================
  // SNACKBAR
  // ============================================================

//   ScaffoldMessenger.of(context).hideCurrentSnackBar();

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       behavior: SnackBarBehavior.floating,
//       content: Text(
//         isSaved
//             ? 'Removed from saved blogs'
//             : 'Saved to My Saved Blogs',
//       ),
//       duration: const Duration(seconds: 2),
//     ),
//   );
// }

  // ============================================================
  // REMOVE SAVED DIALOG
  // ============================================================

  Future<bool?> _showRemoveSavedDialog(BuildContext context, BlogModel blog) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22), // Smooth modern corners
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
          contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          // Symmetrical bottom padding for the buttons
          actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          title: const Text(
            'Remove saved blog?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          content: Text(
            'Remove "${blog.title}" from your saved blogs?',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
          actions: [
            Row(
              children: [
                // 1. MODERN & CLEAN CANCEL BUTTON
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF475467),
                      backgroundColor: const Color(
                        0xFFF2F4F7,
                      ), // Soft grey background fill
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Balanced gap between actions
                // 2. BOLD & ATTENTION-GRABBING REMOVE BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFD92D20,
                      ), // Alert red color
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CLEAR RECENTLY VIEWED
  // ============================================================

  Future<void> _showClearRecentDialog(
    BuildContext context,
    BlogProvider provider,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22), // Smooth modern corners
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
          contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
          // Symmetrical bottom padding for the button action row
          actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          title: const Text(
            'Clear recently viewed?',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          content: const Text(
            'All recently viewed blogs will be removed from your history.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
          actions: [
            Row(
              children: [
                // 1. MODERN & CLEAN CANCEL BUTTON
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF475467),
                      backgroundColor: const Color(
                        0xFFF2F4F7,
                      ), // Soft grey background fill
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Balanced gap between actions
                // 2. BOLD & ATTENTION-GRABBING CLEAR BUTTON
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFD92D20,
                      ), // Clear warning red
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldClear != true) {
      return;
    }

    await provider.clearRecentlyViewed();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedFilter = 'All';
    });
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context, BlogProvider provider) {
    final isSearching = provider.searchQuery.trim().isNotEmpty;

    String title;
    String description;
    IconData icon;

    if (isSearching) {
      title = 'No articles found';
      description = 'Try searching with a different keyword.';
      icon = Icons.search_off_rounded;
    } else if (_selectedFilter == 'My Saved Blogs') {
      title = 'No saved blogs';
      description = 'Save useful health articles to find them here later.';
      icon = Icons.bookmark_border_rounded;
    } else if (_selectedFilter == 'Recently Viewed') {
      title = 'No recently viewed blogs';
      description = 'Articles you open will appear here.';
      icon = Icons.history_rounded;
    } else if (_selectedFilter == 'Top Viewed') {
      title = 'No top viewed blogs';
      description = 'Popular articles will appear here as they are viewed.';
      icon = Icons.trending_up_rounded;
    } else {
      title = 'No articles available';
      description = 'There are no articles in this category yet.';
      icon = Icons.article_outlined;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 36, color: const Color(0xFF1976D2)),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF667085),
              ),
            ),

            const SizedBox(height: 18),

            if (_selectedFilter != 'All')
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All';
                  });
                },
                child: const Text('View all blogs'),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FILTER CHIP
// ============================================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF1976D2) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFEAECF0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF475467),
                ),
              ),

              if (count != null) ...[
                const SizedBox(width: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.18)
                        : const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : const Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
