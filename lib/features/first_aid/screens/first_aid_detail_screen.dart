import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/first_aid_model.dart';
import '../providers/first_aid_provider.dart';

class FirstAidDetailScreen extends StatelessWidget {
  const FirstAidDetailScreen({super.key, required this.item});

  final FirstAidModel item;

  Future<void> _toggleSaved(
    BuildContext context,
    FirstAidProvider provider,
  ) async {
    final isSaved = provider.isSaved(item.id);

// ============================================================
// REMOVE SAVED GUIDE
// ============================================================

if (isSaved) {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
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
        // Symmetrical padding for the button area
        actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 22), 
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
                    backgroundColor: const Color(0xFFF2F4F7), // Soft background instead of a thin border
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
                    backgroundColor: const Color(0xFFD92D20), // Alert red
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
}


    // ============================================================
    // SAVE / REMOVE
    // ============================================================

    await provider.toggleSaved(item.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          isSaved ? 'Removed from saved guides' : 'Saved to My Saved First Aid',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FirstAidProvider>();
    final isSaved = provider.isSaved(item.id);

    final isEmergency = item.category.toLowerCase() == 'emergency';

    final primaryColor = isEmergency
        ? const Color(0xFFD92D20)
        : const Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'First Aid Guide',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B4D),
          ),
        ),
        actions: [
          IconButton(
            tooltip: isSaved ? 'Remove from saved' : 'Save guide',
            onPressed: () {
              _toggleSaved(context, provider);
            },
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved
                  ? const Color(0xFF1976D2)
                  : const Color(0xFF667085),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // HERO
            // ============================================================
            _buildHero(
              primaryColor: primaryColor,
              isEmergency: isEmergency,
              isSaved: isSaved,
            ),

            const SizedBox(height: 24),

            // ============================================================
            // QUICK INFORMATION
            // ============================================================
            _buildQuickInfo(),

            const SizedBox(height: 26),

            // ============================================================
            // WHAT TO DO
            // ============================================================
            _SectionHeader(
              icon: Icons.check_circle_outline_rounded,
              title: 'What to do',
              color: const Color(0xFF12B76A),
            ),

            const SizedBox(height: 12),

            ...List.generate(
              item.steps.length,
              (index) => _StepCard(number: index + 1, text: item.steps[index]),
            ),

            const SizedBox(height: 18),

            // ============================================================
            // DO NOT
            // ============================================================
            _SectionHeader(
              icon: Icons.block_outlined,
              title: 'What not to do',
              color: const Color(0xFFD92D20),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: Column(
                children: item.doNot
                    .map((text) => _DoNotRow(text: text))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ============================================================
            // WHEN TO CALL EMERGENCY
            // ============================================================
            _EmergencyWarning(text: item.whenToCallEmergency),

            const SizedBox(height: 28),

            // ============================================================
            // FUTURE MEDIA SECTION
            // ============================================================
            const _FutureSection(
              icon: Icons.play_circle_outline_rounded,
              title: 'Photo & Video Guide',
              subtitle: 'Visual first-aid instructions will appear here.',
            ),

            const SizedBox(height: 12),

            // ============================================================
            // FUTURE DOCTOR RECOMMENDATIONS
            // ============================================================
            const _FutureSection(
              icon: Icons.medical_services_outlined,
              title: 'Recommended Doctors',
              subtitle: 'Relevant doctors and specialists will appear here.',
            ),

            const SizedBox(height: 12),

            // ============================================================
            // FUTURE NEARBY HOSPITALS
            // ============================================================
            const _FutureSection(
              icon: Icons.location_on_outlined,
              title: 'Nearby Medical Help',
              subtitle:
                  'Nearby hospitals, clinics and emergency facilities will appear here.',
            ),

            const SizedBox(height: 12),

            // ============================================================
            // FUTURE PRODUCTS
            // ============================================================
            const _FutureSection(
              icon: Icons.medical_information_outlined,
              title: 'Recommended First Aid Products',
              subtitle:
                  'Relevant first-aid kits, equipment and other products will appear here.',
            ),

            const SizedBox(height: 30),

            // ============================================================
            // IMPORTANT
            // ============================================================
            _buildImportantNote(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // HERO
  // ========================================================================

  Widget _buildHero({
    required Color primaryColor,
    required bool isEmergency,
    required bool isSaved,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isEmergency ? const Color(0xFFFFF4F2) : const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isEmergency
              ? const Color(0xFFFECACA)
              : const Color(0xFFD1E9FF),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(item.icon, style: const TextStyle(fontSize: 48)),
          ),

          const SizedBox(height: 16),

          // Category
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.category,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 9),

          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 16),

          // Saved status
          if (isSaved)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_rounded, size: 15, color: primaryColor),
                const SizedBox(width: 5),
                Text(
                  'Saved to My First Aid',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ========================================================================
  // QUICK INFO
  // ========================================================================

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: _QuickInfoCard(
            icon: Icons.format_list_numbered_rounded,
            title: '${item.steps.length}',
            subtitle: 'Steps',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickInfoCard(
            icon: Icons.block_outlined,
            title: '${item.doNot.length}',
            subtitle: 'Things to avoid',
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _QuickInfoCard(
            icon: Icons.verified_outlined,
            title: 'Guide',
            subtitle: 'Basic help',
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // IMPORTANT NOTE
  // ========================================================================

  Widget _buildImportantNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 21, color: Color(0xFF667085)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This information is for general first-aid guidance and does not replace professional medical advice, diagnosis or emergency services.',
              style: TextStyle(
                fontSize: 12,
                height: 1.55,
                color: Color(0xFF667085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STEP CARD
// ============================================================================

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF475467),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DO NOT ROW
// ============================================================================

class _DoNotRow extends StatelessWidget {
  const _DoNotRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 15,
              color: Color(0xFFD92D20),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: Color(0xFF475467),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMERGENCY WARNING
// ============================================================================

class _EmergencyWarning extends StatelessWidget {
  const _EmergencyWarning({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emergency_outlined,
                color: Color(0xFFD92D20),
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'When to get emergency help',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7A271A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Color(0xFF912018),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUICK INFO CARD
// ============================================================================

class _QuickInfoCard extends StatelessWidget {
  const _QuickInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF1976D2)),

          const SizedBox(height: 6),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FUTURE SECTION
// ============================================================================

class _FutureSection extends StatelessWidget {
  const _FutureSection({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: const Color(0xFF1976D2), size: 23),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}
