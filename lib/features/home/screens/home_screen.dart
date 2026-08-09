import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';
import '../../blogs/screens/blogs_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigateToTab});

  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    final String userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim().split(' ').first
        : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        titleSpacing: 20,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good day 👋',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              userName,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // EMERGENCY SOS
              // =================================================
              _EmergencyCard(),

              const SizedBox(height: 24),

              // =================================================
              // QUICK ACTIONS
              // =================================================
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.medical_services_outlined,
                      title: 'First Aid',
                      subtitle: 'Learn & help',
                      iconColor: const Color(0xFF1976D2),
                      onTap: () {
                        onNavigateToTab(1);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.emergency_outlined,
                      title: 'Emergency',
                      subtitle: 'Get help',
                      iconColor: const Color(0xFFD92D20),
                      onTap: () {
                        onNavigateToTab(2);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.location_on_outlined,
                      title: 'Nearby Care',
                      subtitle: 'Find services',
                      iconColor: const Color(0xFF12B76A),
                      onTap: () {
                        onNavigateToTab(3);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contacts',
                      subtitle: 'Emergency contacts',
                      iconColor: const Color(0xFFF79009),
                      onTap: () {
                        onNavigateToTab(2);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =================================================
              // HEALTH INFORMATION
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Health Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BlogsScreen()),
                      );
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _InformationCard(
                icon: Icons.health_and_safety_outlined,
                title: 'First Aid Basics',
                description:
                    'Know what to do when someone needs immediate help.',
                onTap: () {
                  onNavigateToTab(1);
                },
              ),

              const SizedBox(height: 12),

              _InformationCard(
                icon: Icons.warning_amber_rounded,
                title: 'Emergency Preparedness',
                description: 'Be prepared before an emergency happens.',
                onTap: () {
                  onNavigateToTab(2);
                },
              ),

              const SizedBox(height: 28),

              // =================================================
              // BLOGS
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Latest from GoCare',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Blogs coming soon')),
                      );
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _BlogCard(
                title: 'What to do during a medical emergency?',
                category: 'Emergency',
                icon: Icons.local_hospital_outlined,
              ),

              const SizedBox(height: 12),

              _BlogCard(
                title: '5 important first aid steps everyone should know',
                category: 'First Aid',
                icon: Icons.medical_information_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// EMERGENCY CARD
// =============================================================

class _EmergencyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD92D20),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD92D20).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 30),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Get emergency assistance quickly.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency feature coming soon')),
              );
            },
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            icon: const Icon(Icons.arrow_forward, color: Color(0xFFD92D20)),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// QUICK ACTION CARD
// =============================================================

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
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
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 25),
              ),

              const SizedBox(height: 14),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
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
// INFORMATION CARD
// =============================================================

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF1976D2), size: 26),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF667085),
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

// =============================================================
// BLOG CARD
// =============================================================

class _BlogCard extends StatelessWidget {
  const _BlogCard({
    required this.title,
    required this.category,
    required this.icon,
  });

  final String title;
  final String category;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1976D2), size: 30),
          ),

          const SizedBox(width: 14),

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
                    color: const Color(0xFFEAF4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
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
    );
  }
}
