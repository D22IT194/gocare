import 'package:flutter/material.dart';

import '../models/blog_model.dart';

class BlogCard extends StatelessWidget {
  const BlogCard({
    super.key,
    required this.blog,
    required this.onTap,
    required this.isSaved,
    required this.onSave,
  });

  final BlogModel blog;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEAECF0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // IMAGE
              // ==================================================

              _BlogImage(
                imageUrl: blog.imageUrl,
                isFeatured: blog.isFeatured,
                isSponsored: blog.isSponsored,
                isSaved: isSaved,
                onSave: onSave,
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // CATEGORY
                    // ------------------------------------------------

                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFEAF4FF),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              blog.category,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    Color(0xFF175CD3),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        if (blog.isSponsored)
                          const _SmallLabel(
                            icon:
                                Icons.campaign_outlined,
                            text: 'Sponsored',
                          ),

                        if (blog.isFeatured &&
                            !blog.isSponsored)
                          const _SmallLabel(
                            icon:
                                Icons.star_outline_rounded,
                            text: 'Featured',
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------

                    Text(
                      blog.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.3,
                        fontWeight:
                            FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // ------------------------------------------------
                    // DESCRIPTION
                    // ------------------------------------------------

                    Text(
                      blog.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ------------------------------------------------
                    // FOOTER
                    // ------------------------------------------------

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 16,
                          color: Color(0xFF98A2B3),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          blog.readTime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(0xFF667085),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: Color(0xFF98A2B3),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            blog.authorName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Color(0xFF667085),
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.chevron_right_rounded,
                          color:
                              Color(0xFF98A2B3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// BLOG IMAGE
// ============================================================================

class _BlogImage extends StatelessWidget {
  const _BlogImage({
    required this.imageUrl,
    required this.isFeatured,
    required this.isSponsored,
    required this.isSaved,
    required this.onSave,
  });

  final String imageUrl;
  final bool isFeatured;
  final bool isSponsored;
  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // --------------------------------------------------------
            // IMAGE / FALLBACK
            // --------------------------------------------------------

            if (imageUrl.trim().isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, _, _) =>
                        const _BlogImageFallback(),
                loadingBuilder:
                    (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return const _BlogImageLoading();
                },
              )
            else
              const _BlogImageFallback(),

            // --------------------------------------------------------
            // GRADIENT
            // --------------------------------------------------------

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // --------------------------------------------------------
            // FEATURED / SPONSORED
            // --------------------------------------------------------

            Positioned(
              left: 12,
              top: 12,
              child: Row(
                children: [
                  if (isFeatured)
                    const _ImageBadge(
                      icon:
                          Icons.star_rounded,
                      label: 'Featured',
                    ),

                  if (isFeatured &&
                      isSponsored)
                    const SizedBox(width: 6),

                  if (isSponsored)
                    const _ImageBadge(
                      icon:
                          Icons.campaign_outlined,
                      label: 'Sponsored',
                    ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // SAVE
            // --------------------------------------------------------

            Positioned(
              right: 12,
              top: 12,
              child: Material(
                color: Colors.white.withValues(
                  alpha: 0.94,
                ),
                shape:
                    const CircleBorder(),
                child: InkWell(
                  customBorder:
                      const CircleBorder(),
                  onTap: onSave,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(9),
                    child: Icon(
                      isSaved
                          ? Icons
                              .bookmark_rounded
                          : Icons
                              .bookmark_border_rounded,
                      size: 21,
                      color: isSaved
                          ? const Color(
                              0xFF1976D2,
                            )
                          : const Color(
                              0xFF475467,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// IMAGE FALLBACK
// ============================================================================

class _BlogImageFallback
    extends StatelessWidget {
  const _BlogImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF4FF),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 52,
            color: Color(0xFF1976D2),
          ),
          SizedBox(height: 8),
          Text(
            'Health Blog',
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// IMAGE LOADING
// ============================================================================

class _BlogImageLoading
    extends StatelessWidget {
  const _BlogImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F4F7),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child:
            CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ============================================================================
// IMAGE BADGE
// ============================================================================

class _ImageBadge
    extends StatelessWidget {
  const _ImageBadge({
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
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.94,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color:
                const Color(0xFF175CD3),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
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
// SMALL LABEL
// ============================================================================

class _SmallLabel
    extends StatelessWidget {
  const _SmallLabel({
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
          size: 13,
          color:
              const Color(0xFF667085),
        ),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w700,
            color:
                Color(0xFF667085),
          ),
        ),
      ],
    );
  }
}