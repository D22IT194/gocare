import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../emergency/models/emergency_contact.dart';
import '../../emergency/providers/emergency_provider.dart';
import '../../emergency/services/emergency_call_service.dart';
import '../../emergency/widgets/emergency_contact_card.dart';

class PrimaryContactsScreen extends StatelessWidget {
  const PrimaryContactsScreen({super.key});

  static const EmergencyCallService _callService = EmergencyCallService();

  Future<void> _callContact(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    final isDoctor = contact.type == EmergencyContactType.doctor;

    // Choose thematic colors matching your card design
    final themeColor = isDoctor
        ? const Color(0xFF0E9384)
        : const Color(0xFF1565C0);
    final alertIconBg = isDoctor
        ? const Color(0xFFF0FDFA)
        : const Color(0xFFF0F7FF);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allows user to tap outside to dismiss safely
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Wrap layout perfectly to content height
              children: [
                // Premium top icon accent representing action intent
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: alertIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_forwarded_rounded,
                    color: themeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),

                // Title Headline
                const Text(
                  'Initiate Phone Call?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Formatted Context Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475467),
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Are you sure you want to place a phone call to ',
                      ),
                      TextSpan(
                        text: contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const TextSpan(text: ' at '),
                      TextSpan(
                        text: contact.phone,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                        ),
                      ),
                      const TextSpan(
                        text: '? Standard carrier rates may apply.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Side-by-Side Action Option Layout Buttons
                Row(
                  children: [
                    // Cancel Option Button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF344054),
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm Action Dial Button
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          icon: const Icon(Icons.call_rounded, size: 16),
                          label: const Text(
                            'Call',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF15B79E,
                            ), // Vibrant action green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await _callService.call(contact.phone);

    // Modernized stylish Toast/Snackbar error tracker notification
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating, // Floats card above bottom items
          backgroundColor: const Color(0xFFD92D20), // Alert error red tone
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Unable to start the phone call. Please check your network connection.',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();

    // Filter out the primary personal contacts
    final primaryPersonal = provider.contacts
        .where(
          (contact) =>
              contact.type == EmergencyContactType.personal &&
              contact.isPrimary,
        )
        .toList();

    // Filter out the primary doctor/clinic contacts
    final primaryDoctors = provider.contacts
        .where(
          (contact) =>
              contact.type == EmergencyContactType.doctor && contact.isPrimary,
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Primary Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101828),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEAECF0), height: 1),
        ),
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1565C0),
                strokeWidth: 3,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              children: [
                // 1. Personal Contacts Section (Only shows if not empty)
                if (primaryPersonal.isNotEmpty) ...[
                  const Text(
                    'PERSONAL EMERGENCY CONTACTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...primaryPersonal.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PrimaryContactCard(
                        contact: contact,
                        onCall: () {
                          _callContact(context, contact);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // 2. Doctor/Clinic Contacts Section (Only shows if not empty)
                if (primaryDoctors.isNotEmpty) ...[
                  const Text(
                    'DOCTORS & CLINICS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...primaryDoctors.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PrimaryContactCard(
                        contact: contact,
                        onCall: () {
                          _callContact(context, contact);
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ===========================================================================
// PRIMARY CONTACT CARD (MEDIUM VERSION WITH ACCENT CALL BUTTON)
// ===========================================================================

class _PrimaryContactCard extends StatelessWidget {
  const _PrimaryContactCard({required this.contact, required this.onCall});

  final EmergencyContact contact;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final isDoctor = contact.type == EmergencyContactType.doctor;

    // Soft thematic accents based on type
    final primaryColor = isDoctor
        ? const Color(0xFF0E9384)
        : const Color(0xFF1565C0);
    final iconBgColor = isDoctor
        ? const Color(0xFFF0FDFA)
        : const Color(0xFFF0F7FF);
    final tagBgColor = isDoctor
        ? const Color(0xFFCCFBF1)
        : const Color(0xFFE0F2FE);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101828).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFEAECF0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar, Name/Role, Type Tag
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDoctor
                      ? Icons.medical_services_outlined
                      : Icons.person_search_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Type Marker Tag (Personal vs Doctor / Clinic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tagBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDoctor ? 'Doctor / Clinic' : 'Personal',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF2F4F7), height: 1),
          const SizedBox(height: 14),

          // Details Grid Section
          Wrap(
            runSpacing: 12,
            spacing: 16,
            children: [
              _CompactInfoTile(
                icon: isDoctor
                    ? Icons.badge_outlined
                    : Icons.family_restroom_outlined,
                label: isDoctor ? 'Speciality' : 'Relationship',
                value: isDoctor
                    ? (contact.speciality ?? 'General Practice')
                    : (contact.relationship ?? 'Not Specified'),
              ),
              _CompactInfoTile(
                icon: Icons.phone_android_outlined,
                label: 'Phone',
                value: contact.phone,
              ),
              if (contact.email?.trim().isNotEmpty ?? false)
                _CompactInfoTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: contact.email!,
                ),
              if (contact.address?.trim().isNotEmpty ?? false)
                _CompactInfoTile(
                  icon: Icons.map_outlined,
                  label: 'Address',
                  value: contact.address!,
                  isFullWidth: true,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Enhanced, Full-Width Action Call Button
          SizedBox(
            width: double.infinity,
            height: 40, // Keeps it tight and compact for a medium card
            child: ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone_forwarded_rounded, size: 16),
              label: const Text(
                'Call Contact Now',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor, // Colored button to match the card theme
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// COMPACT INFO TILE SUPPORT WIDGET
// ===========================================================================
class _CompactInfoTile extends StatelessWidget {
  const _CompactInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isFullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = isFullWidth
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;

        return SizedBox(
          width: itemWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF98A2B3)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF98A2B3),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: isFullWidth ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF344054),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===========================================================================
// INFO ROW
// ===========================================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF667085)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF98A2B3),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
