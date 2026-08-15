import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/first_aid_model.dart';
import '../providers/first_aid_provider.dart';

class FirstAidCard extends StatelessWidget {
  const FirstAidCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final FirstAidModel item;
  final VoidCallback onTap;

  // ============================================================
  // SAVE / REMOVE
  // ============================================================

  Future<void> _handleSave(
    BuildContext context,
    FirstAidProvider provider,
  ) async {
    final isSaved = provider.isSaved(item.id);

    // ----------------------------------------------------------
    // SAVE
    // ----------------------------------------------------------

    if (!isSaved) {
      await provider.toggleSaved(item.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          content: Row(
            children: [
              Icon(
                Icons.bookmark_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Guide saved to My Saved First Aid',
                ),
              ),
            ],
          ),
        ),
      );

      return;
    }

// ----------------------------------------------------------
// REMOVE CONFIRMATION
// ----------------------------------------------------------

final confirmed = await showDialog<bool>(
  context: context,
  builder: (dialogContext) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
      contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
      actionsPadding: const EdgeInsets.fromLTRB(22, 16, 22, 22), // Adjusted for symmetrical bottom spacing
      title: const Row(
        children: [
          Icon(
            Icons.bookmark_remove_outlined,
            color: Color(0xFFD92D20),
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Remove saved guide?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        'Remove "${item.title}" from your saved first aid guides?',
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Color(0xFF667085),
        ),
      ),
      actions: [
        Row(
          children: [
            // 1. CLEAN & MODERN CANCEL BUTTON
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF475467),
                  backgroundColor: const Color(0xFFF2F4F7), // Soft grey background instead of a harsh border
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
            const SizedBox(width: 12), // Gap between buttons
            
            // 2. BOLD & ATTENTION-GRABBING REMOVE BUTTON
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD92D20), // Strong warning red
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


    if (confirmed != true || !context.mounted) {
      return;
    }

    // ----------------------------------------------------------
    // REMOVE
    // ----------------------------------------------------------

    await provider.toggleSaved(item.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              Icons.bookmark_remove_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Removed from My Saved First Aid',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirstAidProvider>();

    final isSaved = provider.isSaved(item.id);

    final category = item.category.trim();

    final isEmergency =
        category.toLowerCase() == 'emergency';

    final primaryColor = isEmergency
        ? const Color(0xFFD92D20)
        : const Color(0xFF1976D2);

    final lightColor = isEmergency
        ? const Color(0xFFFFF1F0)
        : const Color(0xFFEAF4FF);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEmergency
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFEAECF0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TOP
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // ICON
                  // ------------------------------------------------

                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Text(
                      item.icon,
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 13),

                  // ------------------------------------------------
                  // CATEGORY + TITLE
                  // ------------------------------------------------

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _CategoryTag(
                          label: category,
                          color: primaryColor,
                          backgroundColor: lightColor,
                          isEmergency: isEmergency,
                        ),

                        const SizedBox(height: 7),

                        Text(
                          item.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.2,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF172B4D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  // ------------------------------------------------
                  // SAVE BUTTON
                  // ------------------------------------------------

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _handleSave(
                          context,
                          provider,
                        );
                      },
                      borderRadius:
                          BorderRadius.circular(30),
                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 180,
                        ),
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSaved
                              ? const Color(0xFFEAF4FF)
                              : const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSaved
                                ? const Color(
                                    0xFFD1E9FF,
                                  )
                                : const Color(
                                    0xFFEAECF0,
                                  ),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration:
                              const Duration(
                            milliseconds: 180,
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons
                                    .bookmark_border_rounded,
                            key: ValueKey(
                              isSaved,
                            ),
                            size: 20,
                            color: isSaved
                                ? const Color(
                                    0xFF1976D2,
                                  )
                                : const Color(
                                    0xFF98A2B3,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF667085),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // DIVIDER
              // ==================================================

              Container(
                height: 1,
                color: const Color(0xFFF2F4F7),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // BOTTOM INFO
              // ==================================================

              Row(
                children: [
                  _InfoChip(
                    icon: Icons
                        .format_list_numbered_rounded,
                    label:
                        '${item.steps.length} steps',
                  ),

                  if (item.doNot.isNotEmpty) ...[
                    const SizedBox(width: 7),
                    _InfoChip(
                      icon: Icons.block_outlined,
                      label:
                          '${item.doNot.length} don\'t',
                    ),
                  ],

                  const Spacer(),

                  const Text(
                    'Read guide',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 2),

                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFF1976D2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CATEGORY TAG
// ============================================================================

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.isEmergency,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final bool isEmergency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEmergency) ...[
            Icon(
              Icons.warning_amber_rounded,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 3),
          ],
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 0.3,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFO CHIP
// ============================================================================

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF667085),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w700,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}