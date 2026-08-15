import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/blog_model.dart';
import '../providers/blog_provider.dart';
import '../widgets/blog_card.dart';

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({
    super.key,
    required this.blog,
  });

  final BlogModel blog;

  @override
  State<BlogDetailScreen> createState() =>
      _BlogDetailScreenState();
}

class _BlogDetailScreenState
    extends State<BlogDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<BlogProvider>().recordView(
        widget.blog.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<BlogProvider>();

    final blog = provider.findById(
          widget.blog.id,
        ) ??
        widget.blog;

    final isSaved =
        provider.isSaved(blog.id);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'Health Blog',
        ),

        actions: [
          IconButton(
            tooltip: isSaved
                ? 'Remove from saved'
                : 'Save blog',
            onPressed: () {
              _handleSave(
                context,
                provider,
                blog,
              );
            },
            icon: Icon(
              isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved
                  ? const Color(0xFF1976D2)
                  : const Color(0xFF667085),
            ),
          ),

          IconButton(
            tooltip: 'Share',
            onPressed: () {
              _shareBlog(blog);
            },
            icon: const Icon(
              Icons.share_outlined,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HERO
            // ==================================================

            _buildHeroImage(blog),

            const SizedBox(height: 20),

            // ==================================================
            // CATEGORY / STATUS
            // ==================================================

            _buildCategoryRow(blog),

            const SizedBox(height: 12),

            // ==================================================
            // TITLE
            // ==================================================

            Text(
              blog.title,
              style: const TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            Text(
              blog.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color:
                    Color(0xFF667085),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // META
            // ==================================================

            _buildMetaRow(blog),

            const SizedBox(height: 22),

            const Divider(
              height: 1,
              color: Color(0xFFEAECF0),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // ARTICLE
            // ==================================================

            const _SectionTitle(
              icon: Icons.article_outlined,
              title: 'Article',
            ),

            const SizedBox(height: 12),

            Text(
              blog.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                color:
                    Color(0xFF344054),
              ),
            ),

            // ==================================================
            // VIDEO
            // ==================================================

            if (blog.videoUrl != null &&
                blog.videoUrl!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 28),

              _buildVideoSection(
                blog.videoUrl!,
              ),
            ],

            // ==================================================
            // TAGS
            // ==================================================

            if (blog.tags.isNotEmpty) ...[
              const SizedBox(height: 28),

              const _SectionTitle(
                icon: Icons.local_offer_outlined,
                title: 'Topics',
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: blog.tags
                    .map(
                      (tag) => _Tag(
                        label: tag,
                      ),
                    )
                    .toList(),
              ),
            ],

            // ==================================================
            // IMPORTANT
            // ==================================================

            const SizedBox(height: 30),

            _buildMedicalDisclaimer(),

            // ==================================================
            // RELATED ARTICLES
            // ==================================================

            const SizedBox(height: 30),

            _buildRelatedBlogs(
              context,
              provider,
              blog,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO IMAGE
  // ============================================================

  Widget _buildHeroImage(
    BlogModel blog,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(22),
      child: SizedBox(
        width: double.infinity,
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (blog.imageUrl
                .trim()
                .isNotEmpty)
              Image.network(
                blog.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, _, _) =>
                        const _HeroFallback(),
              )
            else
              const _HeroFallback(),

            // --------------------------------------------------
            // BOTTOM GRADIENT
            // --------------------------------------------------

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topCenter,
                      end: Alignment
                          .bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --------------------------------------------------
            // SAVED INDICATOR
            // --------------------------------------------------

            if (context
                .read<BlogProvider>()
                .isSaved(blog.id))
              const Positioned(
                right: 14,
                top: 14,
                child: _HeroBadge(
                  icon:
                      Icons.bookmark_rounded,
                  label: 'Saved',
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryRow(
    BlogModel blog,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFEAF4FF),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          child: Text(
            blog.category,
            style: const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF175CD3),
            ),
          ),
        ),

        if (blog.isFeatured)
          const _StatusBadge(
            icon:
                Icons.star_rounded,
            text: 'Featured',
          ),

        if (blog.isSponsored)
          const _StatusBadge(
            icon:
                Icons.campaign_outlined,
            text: 'Sponsored',
          ),
      ],
    );
  }

  // ============================================================
  // META
  // ============================================================

  Widget _buildMetaRow(
    BlogModel blog,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _MetaItem(
          icon:
              Icons.person_outline_rounded,
          text:
              blog.authorName,
        ),

        _MetaItem(
          icon:
              Icons.schedule_outlined,
          text:
              blog.readTime,
        ),

        _MetaItem(
          icon:
              Icons.calendar_today_outlined,
          text:
              blog.publishedAt,
        ),
      ],
    );
  }

  // ============================================================
  // VIDEO
  // ============================================================

  Widget _buildVideoSection(
    String videoUrl,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFFFF4F2),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.play_circle_outline_rounded,
              color:
                  Color(0xFFD92D20),
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch explanation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Watch a visual explanation of this topic.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color:
                        Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _openVideo(
                videoUrl,
              );
            },
            icon: const Icon(
              Icons.open_in_new_rounded,
              color:
                  Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildMedicalDisclaimer() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF4F2),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              const Color(0xFFFECACA),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color:
                Color(0xFFD92D20),
            size: 22,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF7A271A),
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'This article is for general educational information and does not replace professional medical advice, diagnosis or treatment. Seek qualified medical assistance when needed.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color:
                        Color(0xFF912018),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RELATED BLOGS
  // ============================================================

  Widget _buildRelatedBlogs(
    BuildContext context,
    BlogProvider provider,
    BlogModel currentBlog,
  ) {
    final related = provider.blogs
        .where(
          (blog) =>
              blog.id != currentBlog.id &&
              blog.category.toLowerCase() ==
                  currentBlog.category
                      .toLowerCase(),
        )
        .take(3)
        .toList();

    if (related.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon:
              Icons.auto_awesome_outlined,
          title:
              'Related Articles',
        ),

        const SizedBox(height: 12),

        ...related.map(
          (blog) => Padding(
            padding:
                const EdgeInsets.only(
              bottom: 12,
            ),
            child: BlogCard(
              blog: blog,
              isSaved:
                  provider.isSaved(
                blog.id,
              ),
              onSave: () {
                _handleRelatedSave(
                  context,
                  provider,
                  blog,
                );
              },
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BlogDetailScreen(
                      blog: blog,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
    final isSaved =
        provider.isSaved(
      blog.id,
    );

    if (isSaved) {
      final confirmed =
          await _showRemoveSavedDialog(
        context,
        blog,
      );

      if (confirmed != true) {
        return;
      }
    }

    await provider.toggleSaved(
      blog.id,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content: Text(
          isSaved
              ? 'Removed from saved blogs'
              : 'Saved to My Saved Blogs',
        ),
        duration:
            const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  // ============================================================
  // RELATED SAVE
  // ============================================================

  Future<void> _handleRelatedSave(
    BuildContext context,
    BlogProvider provider,
    BlogModel blog,
  ) async {
    final isSaved =
        provider.isSaved(
      blog.id,
    );

    if (isSaved) {
      final confirmed =
          await _showRemoveSavedDialog(
        context,
        blog,
      );

      if (confirmed != true) {
        return;
      }
    }

    await provider.toggleSaved(
      blog.id,
    );
  }

// ============================================================
// REMOVE SAVE DIALOG
// ============================================================

Future<bool?> _showRemoveSavedDialog(
  BuildContext context,
  BlogModel blog,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22), // Smoother rounded corner
        ),
        titlePadding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
        contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
        // Symmetrical padding for the button action area at the bottom
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
                    backgroundColor: const Color(0xFFF2F4F7), // Soft grey background fill
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
                    backgroundColor: const Color(0xFFD92D20), // Premium warning red
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
  // SHARE
  // ============================================================

  Future<void> _shareBlog(
    BlogModel blog,
  ) async {
    final text = '''
${blog.title}

${blog.description}

Read more on GoCare.
''';

    await Share.share(
      text,
      subject: blog.title,
    );
  }

  // ============================================================
  // OPEN VIDEO
  // ============================================================

  Future<void> _openVideo(
    String url,
  ) async {
    // The actual URL launch/video-player
    // integration will be added in the media phase.
    //
    // Keeping this method isolated means we can
    // later replace it with url_launcher or a
    // video player without changing the UI.
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color:
              const Color(0xFF1976D2),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            title,
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172B4D),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// META ITEM
// ============================================================================

class _MetaItem
    extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color:
              const Color(0xFF98A2B3),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
            color:
                Color(0xFF667085),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAG
// ============================================================================

class _Tag
    extends StatelessWidget {
  const _Tag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF2F4F7),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        '#$label',
        style:
            const TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
          color:
              Color(0xFF475467),
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF2F4F7),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color:
                const Color(0xFF667085),
          ),

          const SizedBox(width: 4),

          Text(
            text,
            style:
                const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HERO BADGE
// ============================================================================

class _HeroBadge
    extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.94,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                const Color(0xFF1976D2),
          ),

          const SizedBox(width: 4),

          Text(
            label,
            style:
                const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF344054),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HERO FALLBACK
// ============================================================================

class _HeroFallback
    extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          const Color(0xFFEAF4FF),
      alignment:
          Alignment.center,
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 68,
            color:
                Color(0xFF1976D2),
          ),
          SizedBox(height: 10),
          Text(
            'Health Blog',
            style:
                TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }
}