import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';

import '../../blogs/screens/blogs_screen.dart';

import '../../emergency/models/emergency_contact.dart';
import '../../emergency/providers/emergency_provider.dart';
import '../../emergency/screens/emergency_contacts_screen.dart';
import '../../emergency/screens/emergency_screen.dart';

import '../../first_aid/screens/first_aid_screen.dart';

import '../../healthcare/screens/appointments_screen.dart';
import '../../healthcare/screens/doctors_screen.dart';
import '../../healthcare/screens/healthcare_facilities_screen.dart';

import '../../medicine/screens/medicine_screen.dart';
import '../../medical_equipment/screens/medical_equipment_screen.dart';

import '../../nearby/screens/nearby_screen.dart';
import 'primary_contact_screen.dart';

import '../../healthcare/screens/appointments_screen.dart';
import '../../healthcare/screens/doctors_screen.dart';
import '../../healthcare/screens/hospitals_screen.dart';
import '../../healthcare/screens/nearby_doctors_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

import '../../notifications/providers/notification_provider.dart';

import '../../profile/models/health_information.dart';
import '../../profile/screens/health_information_screen.dart';
import '../../profile/screens/medical_card_screen.dart';

import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onNavigateToTab});

  final ValueChanged<int> onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// final notificationProvider = context.watch<NotificationProvider>();

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;
      if (user == null) return;

      context.read<HomeProvider>().initialize(userId: user.uid);
    });
  }

  // ============================================================
  // EMERGENCY
  // ============================================================

  void _openEmergency() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
    );
  }

  // ============================================================
  // PRIMARY CONTACT
  // ============================================================

  Future<void> _openPrimaryContact() async {
    final homeProvider = context.read<HomeProvider>();

    final hasPersonalPrimary = homeProvider.primaryPersonalContact != null;

    final hasDoctorPrimary = homeProvider.primaryDoctorContact != null;

    final hasAnyPrimary = hasPersonalPrimary || hasDoctorPrimary;

    // ============================================================
    // NO PRIMARY CONTACT
    // ============================================================

    if (!hasAnyPrimary) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
      );

      if (!mounted) {
        return;
      }

      await homeProvider.refreshPrimaryContacts();

      return;
    }

    // ============================================================
    // PRIMARY CONTACT EXISTS
    // ============================================================

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrimaryContactsScreen()),
    );

    if (!mounted) {
      return;
    }

    await homeProvider.refreshPrimaryContacts();
  }

  // ============================================================
  // PRIMARY CONTACT BOTTOM SHEET
  // ============================================================

  void _showPrimaryContactBottomSheet(EmergencyContact contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _PrimaryContactBottomSheet(
          contact: contact,
          onCall: () {
            Navigator.pop(context);

            _callPrimaryContact(contact);
          },
        );
      },
    );
  }

  // ============================================================
  // CALL PRIMARY CONTACT
  // ============================================================

  void _callPrimaryContact(EmergencyContact contact) {
    /*
     * Connect your existing EmergencyCallService here.
     *
     * Example:
     *
     * final service = EmergencyCallService();
     * service.call(contact.phone);
     *
     * Keep your existing service implementation.
     */

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call ${contact.name}: ${contact.phone}')),
    );
  }

  // ============================================================
  // HEALTH CARD
  // ============================================================

  Future<void> _openHealthCard() async {
    final homeProvider = context.read<HomeProvider>();

    // Decide which screen to open using current data.
    if (homeProvider.isHealthInformationComplete) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicalCardScreen()),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HealthInformationScreen()),
      );
    }

    if (!mounted) {
      return;
    }

    // IMPORTANT:
    // Always fetch the latest Firestore health information
    // after coming back from the health information screen.
    await homeProvider.refreshHealthInformation();
  }
  // ============================================================
  // EMERGENCY CONTACTS
  // ============================================================

  Future<void> _openEmergencyContacts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
    );

    if (!mounted) {
      return;
    }

    await context.read<HomeProvider>().refreshPrimaryContacts();
  }
  // ============================================================
  // FIRST AID
  // ============================================================

  void _openFirstAid() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FirstAidScreen()),
    );
  }

  // ============================================================
  // NEARBY
  // ============================================================

  void _openNearby() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyScreen()),
    );
  }

  // ============================================================
  // DOCTORS
  // ============================================================

  void _openDoctors() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const DoctorsScreen(),
      ),
    );
  }

  // ============================================================
  // HOSPITALS
  // ============================================================

void _openHospitals() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HealthcareFacilitiesScreen(),
    ),
  );
}

  // ============================================================
  // APPOINTMENTS
  // ============================================================

  void _openAppointments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AppointmentsScreen(),
      ),
    );
  }

  // ============================================================
  // BLOGS
  // ============================================================

  void _openBlogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlogsScreen()),
    );
  }

  // ============================================================
  // MEDICINE INFORMATION
  // ============================================================

  void _openMedicineInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicinesScreen()),
    );
  }

  void _openMedicalEquipment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicalEquipmentScreen()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final authProvider = context.watch<AuthProvider>();

    final emergencyProvider = context.watch<EmergencyProvider>();

    final homeProvider = context.watch<HomeProvider>();

    final user = authProvider.user;

    final userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim().split(' ').first
        : 'User';

    final primaryContact = homeProvider.primaryPersonalContact;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16, // Snug modern padding from screen edges
        // Custom Bottom Divider Line for a crisp look
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF2F4F7), // Super soft border line
            height: 1,
          ),
        ),

        // 1. Dashboard User Greeting Section
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Hello',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF667085),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Hand wave emoji wrapper to make sure line heights match perfectly
                  const Text('👋', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101828), // High-contrast modern dark slate
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        // 2. Dashboard Actions Section (Notification & Profile)
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Elegant Notification Action Button Container
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: const Color(
                          0xFFF8FAFC,
                        ), // Ultra-soft slate grey circle background
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _openNotifications,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFFEAECF0,
                                ), // Subtle inner outline
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(
                                0xFF344054,
                              ), // Modern charcoal grey icon color
                              size: 22,
                            ),
                          ),
                        ),
                      ),

                      // High-End Micro Notification Red Badge Block
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: -1,
                          top: -1,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF04438,
                              ), // Modern vibrant error-red tone
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5, // Crisp outer layout masking ring
                              ),
                            ),
                            child: Center(
                              child: Text(
                                notificationProvider.unreadCount > 99
                                    ? '99+'
                                    : '${notificationProvider.unreadCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
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
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await homeProvider.refresh();
          },

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =================================================
                // EMERGENCY ASSISTANCE
                // =================================================
                _EmergencyCard(onTap: _openEmergency),

                const SizedBox(height: 28),

                // =================================================
                // MY HEALTH
                // =================================================
                const _SectionTitle(title: 'My Health'),

                const SizedBox(height: 14),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // PRIMARY CONTACT
                    Expanded(
                      child: _PrimaryContactCard(
                        contact: primaryContact,

                        isLoading:
                            homeProvider.isLoadingPrimaryContacts &&
                            !homeProvider.initialized,

                        onTap: _openPrimaryContact,

                        onCall: primaryContact != null
                            ? () {
                                _callPrimaryContact(primaryContact);
                              }
                            : null,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // HEALTH CARD
                    Expanded(
                      child: _HealthCard(
                        isLoading: homeProvider.isLoadingHealthInformation,
                        healthInformation: homeProvider.healthInformation,
                        onTap: _openHealthCard,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // QUICK ACTIONS
                // =================================================
                const _SectionTitle(title: 'Quick Actions'),

                const SizedBox(height: 14),

                _QuickActions(
                  onFirstAid: _openFirstAid,

                  onNearby: _openNearby,

                  onContacts: _openEmergencyContacts,

                  onDoctors: _openDoctors,

                  onHospitals: _openHospitals,

                  onAppointments: _openAppointments,

                  onBlogs: _openBlogs,

                  onMedicine: _openMedicineInformation,

                  onMedicalEquipment: _openMedicalEquipment,
                ),

                const SizedBox(height: 32),

                // =================================================
                // FIRST AID
                // =================================================
                _FirstAidHomeSection(onViewAll: _openFirstAid),

                const SizedBox(height: 32),

                // =================================================
                // BLOGS
                // =================================================
                _BlogHomeSection(onViewAll: _openBlogs),

                const SizedBox(height: 32),

                // =================================================
                // RECOMMENDATIONS
                // =================================================
                _RecommendationsSection(
                  onDoctors: _openDoctors,

                  onHospitals: _openHospitals,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// EMERGENCY CARD (PREMIUM REDESIGN)
// ==================================================================

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Soft, glowing shadow beneath the card
          BoxShadow(
            color: const Color(0xFFD92D20).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: const Color(0xFFD92D20), // Rich, vibrant emergency red
        borderRadius: BorderRadius.circular(24),
        clipBehavior:
            Clip.antiAlias, // Ensures the splash animation stays bounded
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: Stack(
            children: [
              // Decorative Background Layer: Top-right ambient ring for a high-end feel
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 18,
                    ),
                  ),
                ),
              ),

              // Main content layout layer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    // 1. Left Side: Clean Glassmorphic Icon Container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // 2. Center: Crisp Typography Hierarchy Block
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Emergency Assistance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Get emergency help instantly',
                            style: TextStyle(
                              color: Color(
                                0xFFFEE4E2,
                              ), // Super soft pinkish-white tint
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Right Side: Elegant Indicator Chevron Box
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
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

class _PrimaryContactSkeleton extends StatefulWidget {
  const _PrimaryContactSkeleton();

  @override
  State<_PrimaryContactSkeleton> createState() =>
      _PrimaryContactSkeletonState();
}

class _PrimaryContactSkeletonState extends State<_PrimaryContactSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 44, height: 44, radius: 13),

          const SizedBox(height: 11),

          _box(width: 100, height: 14),

          const SizedBox(height: 8),

          _box(width: double.infinity, height: 11),

          const SizedBox(height: 10),

          _box(width: 95, height: 12),
        ],
      ),
    );
  }
}

class _HealthCardSkeleton extends StatefulWidget {
  const _HealthCardSkeleton();

  @override
  State<_HealthCardSkeleton> createState() => _HealthCardSkeletonState();
}

class _HealthCardSkeletonState extends State<_HealthCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 44, height: 44, radius: 13),

          const SizedBox(height: 11),

          _box(width: 85, height: 14),

          const SizedBox(height: 8),

          _box(width: double.infinity, height: 11),

          const SizedBox(height: 10),

          _box(width: 110, height: 12),
        ],
      ),
    );
  }
}

// ==================================================================
// PRIMARY CONTACT CARD
// ==================================================================

class _PrimaryContactCard extends StatelessWidget {
  const _PrimaryContactCard({
    required this.contact,
    required this.isLoading,
    required this.onTap,
    this.onCall,
  });

  final EmergencyContact? contact;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _PrimaryContactSkeleton();
    }

    final hasContact = contact != null;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.transparent, // Keeps the ripple splash visible
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.contact_phone_outlined,
                  color: Color(0xFFD92D20),
                  size: 23,
                ),
              ),
              const SizedBox(height: 11),
              const Text(
                'Primary Contact',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),
              const SizedBox(height: 6), // Added spacing before the action row

              Text(
                hasContact
                    ? 'View your emergency contact'
                    : 'Add emergency contact',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
              ),
              const SizedBox(height: 10), // Added spacing before the action row

              Row(
                children: [
                  Text(
                    hasContact ? 'View Contact' : 'Add Contact',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD92D20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: Color(0xFFD92D20),
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

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.isLoading,
    required this.healthInformation,
    required this.onTap,
  });

  final bool isLoading;
  final HealthInformation? healthInformation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _HealthCardSkeleton();
    }

    final information = healthInformation;

    final isComplete =
        information != null && _isHealthInformationComplete(information);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFF1976D2),
                  size: 23,
                ),
              ),

              const SizedBox(height: 11),

              const Text(
                'Health Card',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                isComplete
                    ? 'View your medical card'
                    : 'Add health information',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    isComplete ? 'View Health Card' : 'Add Information',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
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

  bool _isHealthInformationComplete(HealthInformation information) {
    // ------------------------------------------------------------
    // PERSONAL INFORMATION
    // ------------------------------------------------------------

    final personalInformationComplete =
        information.dateOfBirth != null &&
        _hasValue(information.gender) &&
        _hasValue(information.bloodGroup);

    // ------------------------------------------------------------
    // BODY INFORMATION
    // ------------------------------------------------------------

    final bodyInformationComplete =
        information.height != null && information.weight != null;

    // ------------------------------------------------------------
    // MEDICAL INFORMATION
    // ------------------------------------------------------------

    final medicalInformationComplete =
        _hasValue(information.allergies) &&
        _hasValue(information.medicalConditions) &&
        _hasValue(information.currentMedications);

    // ------------------------------------------------------------
    // EMERGENCY INFORMATION
    // ------------------------------------------------------------

    final emergencyInformationComplete = _hasValue(information.emergencyNotes);

    return personalInformationComplete &&
        bodyInformationComplete &&
        medicalInformationComplete &&
        emergencyInformationComplete;
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

// ==================================================================
// PRIMARY CONTACT BOTTOM SHEET
// ==================================================================

class _PrimaryContactBottomSheet extends StatelessWidget {
  const _PrimaryContactBottomSheet({
    required this.contact,
    required this.onCall,
  });

  final EmergencyContact contact;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      child: SafeArea(
        top: false,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,

                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),

                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F1),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.contact_phone_outlined,
                    color: Color(0xFFD92D20),
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Primary Contact',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667085),
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        'Emergency contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF172B4D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),

                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: const Color(0xFFEAECF0)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    contact.name,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    contact.phone,

                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: onCall,

                icon: const Icon(Icons.phone_outlined),

                label: const Text('Call Primary Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// QUICK ACTIONS
// ==================================================================

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onFirstAid,
    required this.onNearby,
    required this.onContacts,
    required this.onDoctors,
    required this.onHospitals,
    required this.onAppointments,
    required this.onBlogs,
    required this.onMedicine,
    required this.onMedicalEquipment,
  });

  final VoidCallback onFirstAid;
  final VoidCallback onNearby;
  final VoidCallback onContacts;
  final VoidCallback onDoctors;
  final VoidCallback onHospitals;
  final VoidCallback onAppointments;
  final VoidCallback onBlogs;
  final VoidCallback onMedicine;
  final VoidCallback onMedicalEquipment;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(Icons.medical_services_outlined, 'First Aid', onFirstAid),

      _ActionData(Icons.location_on_outlined, 'Nearby Care', onNearby),

      _ActionData(
        Icons.contact_phone_outlined,
        'Emergency Contacts',
        onContacts,
      ),

      _ActionData(Icons.person_search_outlined, 'Doctors', onDoctors),

      _ActionData(Icons.local_hospital_outlined, 'Hospitals', onHospitals),

      _ActionData(
        Icons.calendar_month_outlined,
        'Appointments',
        onAppointments,
      ),

      _ActionData(Icons.article_outlined, 'Health Blogs', onBlogs),

      _ActionData(
        Icons.medication_outlined,
        'Medicine Information',
        onMedicine,
      ),

      _ActionData(
        Icons.medical_services_outlined,
        'Medical Equipment',
        onMedicalEquipment,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: actions.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 12,

        mainAxisSpacing: 12,

        childAspectRatio: 1.55,
      ),

      itemBuilder: (context, index) {
        final action = actions[index];

        return Material(
          color: Colors.white,

          borderRadius: BorderRadius.circular(17),

          child: InkWell(
            onTap: action.onTap,

            borderRadius: BorderRadius.circular(17),

            child: Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),

                border: Border.all(color: const Color(0xFFEAECF0)),
              ),

              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(
                      action.icon,

                      color: const Color(0xFF1976D2),

                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      action.title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionData {
  const _ActionData(this.icon, this.title, this.onTap);

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

// ==================================================================
// FIRST AID
// ==================================================================

class _FirstAidHomeSection extends StatelessWidget {
  const _FirstAidHomeSection({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return _HomeContentSection(
      title: 'First Aid',

      onViewAll: onViewAll,

      filters: const ['Top Viewed'],

      children: [
        _GuidePreviewCard(
          icon: '🩹',
          title: 'Cuts & Bleeding',
          category: 'Injuries',
          onTap: onViewAll,
        ),

        _GuidePreviewCard(
          icon: '🔥',
          title: 'Burns',
          category: 'Injuries',
          onTap: onViewAll,
        ),

        _GuidePreviewCard(
          icon: '🫁',
          title: 'Choking',
          category: 'Emergency',
          onTap: onViewAll,
        ),
      ],
    );
  }
}

// ==================================================================
// BLOGS
// ==================================================================

class _BlogHomeSection extends StatelessWidget {
  const _BlogHomeSection({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return _HomeContentSection(
      title: 'Health Blogs',

      onViewAll: onViewAll,

      filters: const ['Top Viewed'],

      children: [
        _BlogPreviewCard(
          category: 'Emergency',

          title: 'What to do during a medical emergency?',

          readTime: '4 min read',

          onTap: onViewAll,
        ),

        _BlogPreviewCard(
          category: 'First Aid',

          title: '5 first aid steps everyone should know',

          readTime: '5 min read',

          onTap: onViewAll,
        ),

        _BlogPreviewCard(
          category: 'Safety',

          title: 'How to prepare for an emergency',

          readTime: '6 min read',

          onTap: onViewAll,
        ),
      ],
    );
  }
}

// ==================================================================
// HOME CONTENT SECTION
// ==================================================================

class _HomeContentSection extends StatelessWidget {
  const _HomeContentSection({
    required this.title,
    required this.onViewAll,
    required this.filters,
    required this.children,
  });

  final String title;
  final VoidCallback onViewAll;
  final List<String> filters;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),
            ),

            TextButton(onPressed: onViewAll, child: const Text('View all')),
          ],
        ),

        const SizedBox(height: 4),

        SizedBox(
          height: 38,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: filters.length,

            separatorBuilder: (_, _) => const SizedBox(width: 8),

            itemBuilder: (context, index) {
              final selected = index == 0;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),

                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1976D2) : Colors.white,

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(
                    color: selected
                        ? const Color(0xFF1976D2)
                        : const Color(0xFFEAECF0),
                  ),
                ),

                child: Text(
                  filters[index],

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF475467),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        ...children.map(
          (child) =>
              Padding(padding: const EdgeInsets.only(bottom: 10), child: child),
        ),
      ],
    );
  }
}

// ==================================================================
// FIRST AID PREVIEW CARD
// ==================================================================

class _GuidePreviewCard extends StatelessWidget {
  const _GuidePreviewCard({
    required this.icon,
    required this.title,
    required this.category,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: const Color(0xFFEAECF0)),
          ),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Text(icon, style: const TextStyle(fontSize: 25)),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      category,

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// BLOG PREVIEW CARD
// ==================================================================

class _BlogPreviewCard extends StatelessWidget {
  const _BlogPreviewCard({
    required this.category,
    required this.title,
    required this.readTime,
    required this.onTap,
  });

  final String category;
  final String title;
  final String readTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(16),

        child: Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),

            border: Border.all(color: const Color(0xFFEAECF0)),
          ),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: const Icon(
                  Icons.article_outlined,

                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      category,

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      readTime,

                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// RECOMMENDATIONS
// ==================================================================

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({
    required this.onDoctors,
    required this.onHospitals,
  });

  final VoidCallback onDoctors;
  final VoidCallback onHospitals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recommendations',

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),
            ),

            TextButton(onPressed: onDoctors, child: const Text('Explore')),
          ],
        ),

        const SizedBox(height: 12),

        _RecommendationCard(
          label: 'FEATURED',

          title: 'Find a doctor for your healthcare needs',

          icon: Icons.person_search_outlined,

          onTap: onDoctors,
        ),

        const SizedBox(height: 12),

        _RecommendationCard(
          label: 'SPONSORED',

          title: 'Discover healthcare facilities near you',

          icon: Icons.local_hospital_outlined,

          onTap: onHospitals,
        ),
      ],
    );
  }
}

// ==================================================================
// RECOMMENDATION CARD
// ==================================================================

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.label,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: const Color(0xFFEAECF0)),
          ),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, color: const Color(0xFF1976D2), size: 27),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        label,

                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// SECTION TITLE
// ==================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF172B4D),
      ),
    );
  }
}

// =============================================================
// HEALTHCARE SERVICE CARD
// =============================================================

class _HealthcareServiceCard extends StatelessWidget {
  const _HealthcareServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 25),
              ),

              const SizedBox(height: 14),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// DOCTOR CONSULTATION BANNER
// =============================================================

class _DoctorConsultationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1570EF), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1570EF).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a Doctor?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Book top medical specialists nearby',
                  style: TextStyle(
                    color: Color(0xFFE0E6ED),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoctorsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Color(0xFF1570EF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

