import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/emergency_contact.dart';
import '../services/emergency_call_service.dart';
import '../services/emergency_service.dart';
import 'emergency_contacts_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const EmergencyCallService _callService = EmergencyCallService();

  final EmergencyService _emergencyService = EmergencyService();

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // ============================================================
  // EMERGENCY DRAWER STATE
  // ============================================================

  static const int _primaryContactsSection = -1;

  int? _expandedEmergencySection = _primaryContactsSection;

  // ============================================================
  // PRIMARY CONTACTS FUTURE
  // ============================================================

  late Future<List<EmergencyContact>> _primaryContactsFuture;

  @override
  void initState() {
    super.initState();

    _primaryContactsFuture = _getPrimaryContacts();

    _checkPrimaryContactAndOpenFirstDrawer();
  }

  Future<void> _checkPrimaryContactAndOpenFirstDrawer() async {
    final contacts = await _primaryContactsFuture;

    if (!mounted) return;

    final hasPrimaryContact = contacts.isNotEmpty;

    if (!hasPrimaryContact) {
      setState(() {
        _expandedEmergencySection = 0;
      });
    }
  }

  // ============================================================
  // OPEN EMERGENCY CONTACTS
  // ============================================================

  Future<void> _openEmergencyContacts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
    );

    if (!mounted) return;

    // Always reload contacts when coming back.
    //
    // This is important because EmergencyContactsScreen may
    // Navigator.pop() without returning a boolean result.
    setState(() {
      _primaryContactsFuture = _getPrimaryContacts();
    });
  }

  // ============================================================
  // REFRESH PRIMARY CONTACTS
  // ============================================================

  // void _refreshPrimaryContacts() {
  //   setState(() {
  //     _primaryContactsFuture = _getPrimaryContacts();
  //   });
  // }

  void _toggleEmergencySection(int index) {
    setState(() {
      _expandedEmergencySection = _expandedEmergencySection == index
          ? null
          : index;
    });
  }
  // ============================================================
  // PRIMARY CONTACTS
  // ============================================================

  Future<List<EmergencyContact>> _getPrimaryContacts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final contacts = await _emergencyService.getContacts(userId: user.uid);

    return contacts.where((contact) => contact.isPrimary).toList();
  }

  // ============================================================
  // PRIMARY CONTACTS SECTION
  // ============================================================

  Widget _buildPrimaryContactsSection(BuildContext context) {
    final expanded = _expandedEmergencySection == _primaryContactsSection;

    return FutureBuilder<List<EmergencyContact>>(
      future: _primaryContactsFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _PrimaryContactsSkeleton(
            expanded: _expandedEmergencySection == _primaryContactsSection,
          );
        }

        if (snapshot.hasError) {
          return _buildNoPrimaryContactCard(context);
        }

        final contacts = snapshot.data ?? [];

        // ========================================================
        // PERSONAL PRIMARY
        // ========================================================

        final personalPrimary = contacts
            .where((contact) => contact.type == EmergencyContactType.personal)
            .firstOrNull;

        // ========================================================
        // DOCTOR / CLINIC PRIMARY
        // ========================================================

        final doctorPrimary = contacts
            .where((contact) => contact.type == EmergencyContactType.doctor)
            .firstOrNull;

        // ========================================================
        // NO PRIMARY CONTACT
        // ========================================================

        if (personalPrimary == null && doctorPrimary == null) {
          return _buildNoPrimaryContactCard(context);
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: expanded
                  ? const Color(0xFF1976D2).withValues(alpha: 0.20)
                  : const Color(0xFFE4E7EC),
            ),

            boxShadow: [
              BoxShadow(
                color: expanded
                    ? const Color(0xFF1976D2).withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.015),
                blurRadius: expanded ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: Column(
              children: [
                // ==================================================
                // HEADER
                // ==================================================
                Material(
                  color: Colors.transparent,

                  child: InkWell(
                    onTap: () {
                      _toggleEmergencySection(_primaryContactsSection);
                    },

                    borderRadius: BorderRadius.circular(20),

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),

                      child: Row(
                        children: [
                          // ==================================================
                          // ICON
                          // ==================================================
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),

                            width: 46,
                            height: 46,

                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF4FF),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.star_rounded,
                              color: Color(0xFF1976D2),
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 11),

                          // ==================================================
                          // TITLE
                          // ==================================================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'Your Primary Contacts',

                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF172B4D),
                                  ),
                                ),

                                const SizedBox(height: 3),

                                const Text(
                                  'Quickly call your trusted contacts',

                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF667085),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ==================================================
                          // PRIMARY COUNT
                          // ==================================================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF8FF),

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              '${[if (personalPrimary != null) personalPrimary, if (doctorPrimary != null) doctorPrimary].length}',

                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF175CD3),
                              ),
                            ),
                          ),

                          const SizedBox(width: 4),

                          // ==================================================
                          // ARROW
                          // ==================================================
                          AnimatedRotation(
                            turns: expanded ? 0.5 : 0,

                            duration: const Duration(milliseconds: 200),

                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),

                  firstCurve: Curves.easeOut,

                  secondCurve: Curves.easeIn,

                  crossFadeState: expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,

                  firstChild: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),

                    child: Column(
                      children: [
                        Container(height: 1, color: const Color(0xFFEAECF0)),

                        const SizedBox(height: 12),

                        // ==================================================
                        // PERSONAL PRIMARY
                        // ==================================================
                        if (personalPrimary != null)
                          _PrimaryQuickContactCard(
                            contact: personalPrimary,

                            onCall: () {
                              _confirmContactCall(context, personalPrimary);
                            },
                          ),

                        // ==================================================
                        // DOCTOR PRIMARY
                        // ==================================================
                        if (personalPrimary != null && doctorPrimary != null)
                          const SizedBox(height: 10),

                        if (doctorPrimary != null)
                          _PrimaryQuickContactCard(
                            contact: doctorPrimary,

                            onCall: () {
                              _confirmContactCall(context, doctorPrimary);
                            },
                          ),
                      ],
                    ),
                  ),

                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // NO PRIMARY CONTACT CARD
  // ============================================================

  Widget _buildNoPrimaryContactCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _openEmergencyContacts,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.contact_phone_outlined,
                  color: Color(0xFF1976D2),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Primary Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Set a personal or doctor contact as primary for quick access.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PRIMARY QUICK CONTACT CARD
  // ============================================================

  Widget _buildSecondaryInformation(EmergencyContact contact) {
    final isDoctor = contact.type == EmergencyContactType.doctor;

    final secondaryText = isDoctor ? contact.speciality : contact.relationship;

    if (secondaryText == null || secondaryText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      secondaryText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
    );
  }

  // ============================================================
  // CONFIRM CONTACT CALL
  // ============================================================

  Future<void> _confirmContactCall(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    final isDoctor = contact.type == EmergencyContactType.doctor;

    final confirmed = await _showCallConfirmationSheet(
      context,
      title: 'Call contact?',
      name: contact.name,
      phoneNumber: contact.phone,
      typeLabel: isDoctor ? 'Doctor / Clinic' : 'Personal Contact',
      secondaryLabel: isDoctor ? contact.speciality : contact.relationship,
      color: isDoctor ? const Color(0xFF00A896) : const Color(0xFF1976D2),
      icon: isDoctor ? Icons.local_hospital_outlined : Icons.person_outline,
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await _callService.call(contact.phone);

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Unable to start the phone call.'),
        ),
      );
    }
  }

  Future<bool?> _showCallConfirmationSheet(
    BuildContext context, {
    required String title,
    required String name,
    required String phoneNumber,
    required String typeLabel,
    required Color color,
    required IconData icon,
    String? secondaryLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667085),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAECF0)),
                  ),
                  child: Column(
                    children: [
                      _CallSheetInfoRow(
                        icon: Icons.badge_outlined,
                        color: color,
                        text: typeLabel,
                      ),
                      if (secondaryLabel != null &&
                          secondaryLabel.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _CallSheetInfoRow(
                          icon: Icons.info_outline_rounded,
                          color: color,
                          text: secondaryLabel,
                        ),
                      ],
                      const SizedBox(height: 10),
                      _CallSheetInfoRow(
                        icon: Icons.phone_outlined,
                        color: color,
                        text: phoneNumber,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext, false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF344054),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext, true);
                        },
                        icon: const Icon(Icons.call_rounded, size: 20),
                        label: const Text(
                          'Call Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF12B76A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),
                const Text(
                  'The call will start only after you tap Call Now.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF98A2B3)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EMERGENCY SERVICES
  // ============================================================

  static const List<_EmergencyServiceItem> _emergencyServices = [
    _EmergencyServiceItem(
      title: 'Ambulance',
      subtitle: 'Medical emergency assistance',
      phoneNumber: '102',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFFD92D20),
      category: 'Medical & Health',
    ),

    _EmergencyServiceItem(
      title: 'Police',
      subtitle: 'Police and safety assistance',
      phoneNumber: '100',
      icon: Icons.local_police_outlined,
      color: Color(0xFF1976D2),
      category: 'Safety & Crime',
    ),

    _EmergencyServiceItem(
      title: 'Fire & Rescue',
      subtitle: 'Fire and rescue assistance',
      phoneNumber: '101',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFF04438),
      category: 'Emergency Services',
    ),
  ];

  // ============================================================
  // MEDICAL
  // ============================================================

  static const List<_EmergencyServiceItem> _medicalServices = [
    _EmergencyServiceItem(
      title: 'Ambulance',
      subtitle: 'National Ambulance Service',
      phoneNumber: '102',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFFD92D20),
      category: 'Medical & Health',
    ),

    _EmergencyServiceItem(
      title: 'Health Helpline',
      subtitle: 'Health related assistance',
      phoneNumber: '104',
      icon: Icons.health_and_safety_outlined,
      color: Color(0xFF12B76A),
      category: 'Medical & Health',
    ),
  ];

  // ============================================================
  // WOMEN & CHILDREN
  // ============================================================

  static const List<_EmergencyServiceItem> _womenChildServices = [
    _EmergencyServiceItem(
      title: 'Women Helpline',
      subtitle: 'Women safety and assistance',
      phoneNumber: '181',
      icon: Icons.woman_outlined,
      color: Color(0xFFD946EF),
      category: 'Women & Children',
    ),

    _EmergencyServiceItem(
      title: 'Women in Distress',
      subtitle: 'Immediate women safety assistance',
      phoneNumber: '1091',
      icon: Icons.shield_outlined,
      color: Color(0xFFB42318),
      category: 'Women & Children',
    ),

    _EmergencyServiceItem(
      title: 'Child Helpline',
      subtitle: 'Emergency assistance for children',
      phoneNumber: '1098',
      icon: Icons.child_care_outlined,
      color: Color(0xFFF79009),
      category: 'Women & Children',
    ),
  ];

  // ============================================================
  // SAFETY & CRIME
  // ============================================================

  static const List<_EmergencyServiceItem> _safetyServices = [
    _EmergencyServiceItem(
      title: 'Police',
      subtitle: 'Police and law enforcement',
      phoneNumber: '100',
      icon: Icons.local_police_outlined,
      color: Color(0xFF1976D2),
      category: 'Safety & Crime',
    ),

    _EmergencyServiceItem(
      title: 'Cyber Crime',
      subtitle: 'Report cyber crime and fraud',
      phoneNumber: '1930',
      icon: Icons.security_outlined,
      color: Color(0xFF6941C6),
      category: 'Safety & Crime',
    ),

    _EmergencyServiceItem(
      title: 'Road Accident',
      subtitle: 'Road accident assistance',
      phoneNumber: '1073',
      icon: Icons.car_crash_outlined,
      color: Color(0xFFDC6803),
      category: 'Safety & Crime',
    ),
  ];

  // ============================================================
  // DISASTER
  // ============================================================

  static const List<_EmergencyServiceItem> _disasterServices = [
    _EmergencyServiceItem(
      title: 'Disaster Assistance',
      subtitle: 'Natural calamity assistance',
      phoneNumber: '1070',
      icon: Icons.flood_outlined,
      color: Color(0xFF1570EF),
      category: 'Disaster & Rescue',
    ),

    _EmergencyServiceItem(
      title: 'NDRF / Disaster',
      subtitle: 'Earthquake, flood and disaster assistance',
      phoneNumber: '01124363260',
      icon: Icons.warning_amber_outlined,
      color: Color(0xFFD92D20),
      category: 'Disaster & Rescue',
    ),
  ];

  // ============================================================
  // UTILITY
  // ============================================================

  static const List<_EmergencyServiceItem> _utilityServices = [
    _EmergencyServiceItem(
      title: 'LPG Gas Leak',
      subtitle: 'Report an LPG gas leak',
      phoneNumber: '1906',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFDC6803),
      category: 'Utility Emergencies',
    ),
  ];

  // ============================================================
  // SENIOR / DISABILITY
  // ============================================================

  static const List<_EmergencyServiceItem> _supportServices = [
    _EmergencyServiceItem(
      title: 'Senior Citizens',
      subtitle: 'Senior citizen helpline',
      phoneNumber: '14567',
      icon: Icons.elderly_outlined,
      color: Color(0xFF7F56D9),
      category: 'Support',
    ),

    _EmergencyServiceItem(
      title: 'Disability Helpline',
      subtitle: 'Assistance for persons with disabilities',
      phoneNumber: '14456',
      icon: Icons.accessibility_new_outlined,
      color: Color(0xFF0086C9),
      category: 'Support',
    ),
  ];

  // ============================================================
  // RAILWAY / TRAVEL
  // ============================================================

  static const List<_EmergencyServiceItem> _travelServices = [
    _EmergencyServiceItem(
      title: 'Railway Assistance',
      subtitle: 'Railway security and medical assistance',
      phoneNumber: '139',
      icon: Icons.train_outlined,
      color: Color(0xFF344054),
      category: 'Travel',
    ),
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CALL CONFIRMATION
  // ============================================================

  Future<void> _confirmAndCall(
    BuildContext context, {
    required String service,
    required String phoneNumber,
    required String description,
  }) async {
    final confirmed = await _showCallConfirmationSheet(
      context,
      title: 'Emergency call',
      name: service,
      phoneNumber: phoneNumber,
      typeLabel: 'Emergency Service',
      secondaryLabel: description,
      color: const Color(0xFFD92D20),
      icon: Icons.emergency_outlined,
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await _callService.call(phoneNumber);

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text('Unable to start the phone call.'),
        ),
      );
    }
  }

  // ============================================================
  // 112 CALL
  // ============================================================

  Future<void> _call112(BuildContext context) {
    return _confirmAndCall(
      context,
      service: 'National Emergency',
      phoneNumber: '112',
      description:
          '112 is India\'s unified emergency response number for immediate emergency assistance.',
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<_EmergencyServiceItem> _filterServices(
    List<_EmergencyServiceItem> services,
  ) {
    if (_searchQuery.trim().isEmpty) {
      return services;
    }

    final query = _searchQuery.toLowerCase().trim();

    return services.where((service) {
      return service.title.toLowerCase().contains(query) ||
          service.subtitle.toLowerCase().contains(query) ||
          service.phoneNumber.contains(query) ||
          service.category.toLowerCase().contains(query);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        // Changed to false so the title sits on the left side
        centerTitle: false,
        scrolledUnderElevation: 0,

        // Removed 'const' so the text layout handles left alignment correctly
        title: const Text(
          'Emergency',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),

        actions: [
          Center(
            // Ensures the circle stays perfectly vertically centered in the AppBar
            child: Container(
              decoration: const BoxDecoration(
                color: Color(
                  0xFFEFF8FF,
                ), // Light blue round background matching your badge
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Emergency Contacts',
                // Removes default inner padding so the circle looks perfectly tight
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                onPressed: _openEmergencyContacts,
                // onPressed: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const EmergencyContactsScreen(),
                //     ),
                //   );
                // },
                icon: const Icon(
                  Icons.contact_phone_rounded,
                  color: Color(0xFF175CD3), // Vibrant blue matching your text
                  size:
                      26, // Slightly adjusted for perfect framing inside the circle
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ), // Added a bit more space from the right screen edge
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // HERO
              // ==================================================
              _EmergencyHeroCard(onCall: () => _call112(context)),

              const SizedBox(height: 22),

              // ==================================================
              // SEARCH
              // ==================================================
              _EmergencySearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),

              const SizedBox(height: 22),

              // ==================================================
              // SEARCH RESULTS
              // ==================================================
              if (_searchQuery.trim().isNotEmpty)
                _buildSearchResults()
              else ...[
                // =================================================
                // YOUR PRIMARY CONTACTS — QUICK ACCESS FIRST
                // =================================================
                _buildPrimaryContactsSection(context),

                const SizedBox(height: 22),

                // =================================================
                // EMERGENCY SERVICES
                // =================================================
                _EmergencySection(
                  title: 'Emergency Services',
                  sectionIndex: 0,
                  expanded: _expandedEmergencySection == 0,
                  onToggle: () => _toggleEmergencySection(0),
                  subtitle: 'Immediate emergency assistance',
                  count: _emergencyServices.length,
                  icon: Icons.emergency_outlined,
                  color: const Color(0xFFD92D20),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_emergencyServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // MEDICAL
                // =================================================
                _EmergencySection(
                  title: 'Medical & Health',
                  sectionIndex: 1,
                  expanded: _expandedEmergencySection == 1,
                  onToggle: () => _toggleEmergencySection(1),
                  subtitle: 'Medical and health assistance',
                  count: _emergencyServices.length,
                  icon: Icons.health_and_safety_outlined,
                  color: const Color(0xFF12B76A),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_medicalServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // WOMEN & CHILDREN
                // =================================================
                _EmergencySection(
                  title: 'Women & Children',
                  sectionIndex: 2,
                  expanded: _expandedEmergencySection == 2,
                  onToggle: () => _toggleEmergencySection(2),
                  subtitle: 'Safety and emergency support',
                  count: _emergencyServices.length,
                  icon: Icons.family_restroom_outlined,
                  color: const Color(0xFFD946EF),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_womenChildServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // SAFETY
                // =================================================
                _EmergencySection(
                  title: 'Safety & Crime',
                  sectionIndex: 3,
                  expanded: _expandedEmergencySection == 3,
                  onToggle: () => _toggleEmergencySection(3),
                  subtitle: 'Police, cyber crime and road safety',
                  count: _emergencyServices.length,
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF1976D2),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_safetyServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // DISASTER
                // =================================================
                _EmergencySection(
                  title: 'Disaster & Rescue',
                  sectionIndex: 4,
                  expanded: _expandedEmergencySection == 4,
                  onToggle: () => _toggleEmergencySection(4),
                  subtitle: 'Natural disasters and rescue assistance',
                  count: _emergencyServices.length,
                  icon: Icons.warning_amber_outlined,
                  color: const Color(0xFFDC6803),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_disasterServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // UTILITY
                // =================================================
                _EmergencySection(
                  title: 'Utility Emergencies',
                  sectionIndex: 5,
                  expanded: _expandedEmergencySection == 5,
                  onToggle: () => _toggleEmergencySection(5),
                  subtitle: 'Gas and utility-related emergencies',
                  count: _emergencyServices.length,
                  icon: Icons.build_outlined,
                  color: const Color(0xFFB54708),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_utilityServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // SUPPORT
                // =================================================
                _EmergencySection(
                  title: 'Senior & Disability Support',
                  sectionIndex: 6,
                  expanded: _expandedEmergencySection == 6,
                  onToggle: () => _toggleEmergencySection(6),
                  subtitle: 'Special assistance and support',
                  count: _emergencyServices.length,
                  icon: Icons.accessibility_new_outlined,
                  color: const Color(0xFF7F56D9),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_supportServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // TRAVEL
                // =================================================
                _EmergencySection(
                  title: 'Travel & Railway',
                  sectionIndex: 7,
                  expanded: _expandedEmergencySection == 7,
                  onToggle: () => _toggleEmergencySection(7),
                  subtitle: 'Railway and travel assistance',
                  count: _emergencyServices.length,
                  icon: Icons.train_outlined,
                  color: const Color(0xFF344054),
                  children: [
                    _EmergencyGrid(
                      services: _filterServices(_travelServices),
                      onCall: _confirmServiceCall,
                    ),
                  ],
                ),

                // const SizedBox(height: 26),

                // =================================================
                // MANAGE CONTACTS
                // =================================================
                // _buildMyContactsCard(context),
                const SizedBox(height: 20),

                // =================================================
                // SAFETY NOTICE
                // =================================================
                const _SafetyNotice(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH RESULTS
  // ============================================================

  Widget _buildSearchResults() {
    final allServices = [
      ..._emergencyServices,
      ..._medicalServices,
      ..._womenChildServices,
      ..._safetyServices,
      ..._disasterServices,
      ..._utilityServices,
      ..._supportServices,
      ..._travelServices,
    ];

    final results = _filterServices(allServices);

    final uniqueResults = <String, _EmergencyServiceItem>{};

    for (final service in results) {
      uniqueResults['${service.title}-${service.phoneNumber}'] = service;
    }

    final services = uniqueResults.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${services.length} result${services.length == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF667085),
          ),
        ),

        const SizedBox(height: 12),

        if (services.isEmpty)
          _NoSearchResults(query: _searchQuery)
        else
          _EmergencyGrid(services: services, onCall: _confirmServiceCall),
      ],
    );
  }

  // ============================================================
  // SERVICE CALL
  // ============================================================

  void _confirmServiceCall(_EmergencyServiceItem service) {
    _confirmAndCall(
      context,
      service: service.title,
      phoneNumber: service.phoneNumber,
      description: service.subtitle,
    );
  }

  // ============================================================
  // MY CONTACTS
  // ============================================================

  Widget _buildMyContactsCard(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.contact_phone_outlined,
                  color: Color(0xFF1976D2),
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Emergency Contacts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Call your trusted family members or doctors.',
                      style: TextStyle(
                        fontSize: 13,
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
        ),
      ),
    );
  }
}

// ============================================================================
// EMERGENCY SERVICE MODEL
// ============================================================================

class _EmergencyServiceItem {
  const _EmergencyServiceItem({
    required this.title,
    required this.subtitle,
    required this.phoneNumber,
    required this.icon,
    required this.color,
    required this.category,
  });

  final String title;
  final String subtitle;
  final String phoneNumber;
  final IconData icon;
  final Color color;
  final String category;
}

// ============================================================================
// PRIMARY QUICK CONTACT CARD
// ============================================================================

class _PrimaryQuickContactCard extends StatelessWidget {
  const _PrimaryQuickContactCard({required this.contact, required this.onCall});

  final EmergencyContact contact;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final isDoctor = contact.type == EmergencyContactType.doctor;

    final primaryColor = isDoctor
        ? const Color(0xFF00A896)
        : const Color(0xFF1976D2);

    final secondaryText = isDoctor ? contact.speciality : contact.relationship;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  isDoctor
                      ? Icons.local_hospital_outlined
                      : Icons.person_outline,
                  color: primaryColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          isDoctor
                              ? Icons.local_hospital_outlined
                              : Icons.person_outline,
                          size: 14,
                          color: const Color(0xFF98A2B3),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          contact.type.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667085),
                          ),
                        ),

                        if (secondaryText != null &&
                            secondaryText.trim().isNotEmpty) ...[
                          const SizedBox(width: 6),

                          const Text(
                            '•',
                            style: TextStyle(color: Color(0xFF98A2B3)),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: Color(0xFF667085),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    contact.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF344054),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --------------------------------------------------------
          // EMAIL
          // --------------------------------------------------------
          if (contact.email != null && contact.email!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),

            _PrimaryInfoRow(icon: Icons.email_outlined, text: contact.email!),
          ],

          // --------------------------------------------------------
          // ADDRESS
          // --------------------------------------------------------
          if (contact.address != null &&
              contact.address!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),

            _PrimaryInfoRow(
              icon: Icons.location_on_outlined,
              text: contact.address!,
            ),
          ],

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text(
                'Call Contact',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12B76A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PRIMARY CONTACTS SKELETON
// ============================================================================

class _PrimaryContactsSkeleton extends StatelessWidget {
  const _PrimaryContactsSkeleton({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  _SkeletonBox(width: 46, height: 46, radius: 14),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(width: 155, height: 15, radius: 5),

                        const SizedBox(height: 7),

                        _SkeletonBox(width: 205, height: 11, radius: 4),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  _SkeletonBox(width: 30, height: 24, radius: 20),

                  const SizedBox(width: 6),

                  _SkeletonBox(width: 24, height: 24, radius: 12),
                ],
              ),
            ),

            // ============================================================
            // CONTENT
            // ============================================================
            if (expanded) ...[
              Container(height: 1, color: const Color(0xFFEAECF0)),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  children: [
                    const _PrimaryContactCardSkeleton(),

                    const SizedBox(height: 10),

                    const _PrimaryContactCardSkeleton(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PRIMARY CONTACT CARD SKELETON
// ============================================================================

class _PrimaryContactCardSkeleton extends StatelessWidget {
  const _PrimaryContactCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _SkeletonBox(width: 50, height: 50, radius: 15),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SkeletonBox(width: 120, height: 15, radius: 5),

                    const SizedBox(height: 8),

                    const _SkeletonBox(width: 170, height: 11, radius: 4),
                  ],
                ),
              ),

              const _SkeletonBox(width: 55, height: 22, radius: 20),
            ],
          ),

          const SizedBox(height: 12),

          const _SkeletonBox(width: double.infinity, height: 40, radius: 12),

          const SizedBox(height: 10),

          const _SkeletonBox(width: double.infinity, height: 42, radius: 12),
        ],
      ),
    );
  }
}

// ============================================================================
// SKELETON BOX
// ============================================================================

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,

      builder: (context, child) {
        final opacity = 0.45 + (_controller.value * 0.25);

        return Opacity(
          opacity: opacity,

          child: Container(
            width: widget.width,
            height: widget.height,

            decoration: BoxDecoration(
              color: const Color(0xFFE4E7EC),
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// PRIMARY INFO ROW
// ============================================================================

class _PrimaryInfoRow extends StatelessWidget {
  const _PrimaryInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF98A2B3)),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HERO CARD (CRASH-PROOF MEDIUM HORIZONTAL VERSION)
// ============================================================================

class _EmergencyHeroCard extends StatelessWidget {
  const _EmergencyHeroCard({required this.onCall});

  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3F2), Color(0xFFFFFDFD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFEE4E2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD92D20).withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Left Side: Clean Emergency Icon
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE4E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Color(0xFFD92D20),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // 2. Center: Compact Text Layout
          Expanded(
            flex: 2, // Controls proportions explicitly 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Emergency Help?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF912018),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Call 112 now',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB42318),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 3. Right Side: Wrapped inside Expanded to stop Infinite Width Crashes
          Expanded(
            flex: 2, // Safely shares the row layout width constraints
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.phone_forwarded_rounded, size: 14),
                label: const Text(
                  'CALL 112',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD92D20),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Snug fit padding boundary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================================
// SEARCH FIELD
// ============================================================================

class _EmergencySearchField extends StatelessWidget {
  const _EmergencySearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search emergency service or number...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3)),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF667085),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 19),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CALL SHEET INFO ROW
// ============================================================================

class _CallSheetInfoRow extends StatelessWidget {
  const _CallSheetInfoRow({
    required this.icon,
    required this.color,
    required this.text,
    this.bold = false,
  });

  final IconData icon;
  final Color color;
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: bold ? 17 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold ? const Color(0xFF172B4D) : const Color(0xFF475467),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SECTION
// ============================================================================

class _EmergencySection extends StatelessWidget {
  const _EmergencySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.children,
    required this.sectionIndex,
    required this.expanded,
    required this.onToggle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  final int sectionIndex;
  final bool expanded;
  final VoidCallback onToggle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: expanded
              ? color.withValues(alpha: 0.25)
              : const Color(0xFFEAECF0),
        ),

        boxShadow: [
          BoxShadow(
            color: expanded
                ? color.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.015),
            blurRadius: expanded ? 12 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: Column(
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================
            Material(
              color: Colors.transparent,

              child: InkWell(
                onTap: onToggle,

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Row(
                    children: [
                      // ==================================================
                      // ICON
                      // ==================================================
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),

                        curve: Curves.easeOutCubic,

                        width: 46,
                        height: 46,

                        decoration: BoxDecoration(
                          color: color.withValues(
                            alpha: expanded ? 0.15 : 0.10,
                          ),

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Icon(icon, color: color, size: 24),
                      ),

                      const SizedBox(width: 12),

                      // ==================================================
                      // TITLE + SUBTITLE
                      // ==================================================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              title,

                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF172B4D),
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              subtitle,

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),

                      const SizedBox(width: 5),

                      // ==================================================
                      // ARROW
                      // ==================================================
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,

                        duration: const Duration(milliseconds: 280),

                        curve: Curves.easeOutCubic,

                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,

                          color: Color(0xFF98A2B3),

                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================================
            // SMOOTH CONTENT EXPANSION
            // ==========================================================
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),

                curve: Curves.easeInOutCubic,

                alignment: Alignment.topCenter,

                child: expanded
                    ? Column(
                        children: [
                          // ==================================================
                          // DIVIDER
                          // ==================================================
                          Container(height: 1, color: const Color(0xFFEAECF0)),

                          // ==================================================
                          // CONTENT
                          // ==================================================
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),

                            child: Column(children: children),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GRID
// ============================================================================

class _EmergencyGrid extends StatelessWidget {
  const _EmergencyGrid({required this.services, required this.onCall});

  final List<_EmergencyServiceItem> services;
  final ValueChanged<_EmergencyServiceItem> onCall;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = width >= 600 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 158,
          ),
          itemBuilder: (context, index) {
            final service = services[index];

            return _EmergencyServiceCard(
              service: service,
              onTap: () {
                onCall(service);
              },
            );
          },
        );
      },
    );
  }
}

// ============================================================================
// SERVICE CARD
// ============================================================================

class _EmergencyServiceCard extends StatelessWidget {
  const _EmergencyServiceCard({required this.service, required this.onTap});

  final _EmergencyServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFCFCFD),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: service.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(service.icon, color: service.color, size: 23),
                  ),

                  const Spacer(),

                  Icon(Icons.call_outlined, color: service.color, size: 19),
                ],
              ),

              const Spacer(),

              Text(
                service.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                service.phoneNumber,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: service.color,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                service.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF667085),
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
// EMPTY SEARCH
// ============================================================================

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Color(0xFF98A2B3),
          ),

          const SizedBox(height: 12),

          const Text(
            'No emergency service found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'No result found for "$query".',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SAFETY NOTICE
// ============================================================================

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEDF89)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFB54708), size: 20),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'For an immediate emergency, call 112.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A2E0E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
