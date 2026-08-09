import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/health_information.dart';
import '../services/profile_service.dart';
import '../widgets/health_info_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  HealthInformation? _healthInformation;
  String? _phoneNumber;
  String? _profilePhotoUrl;

  bool _isLoadingHealth = true;

  @override
  void initState() {
    super.initState();

    _loadHealthInformation();
  }

  Future<void> _loadHealthInformation() async {
    try {
      final authProvider = context.read<AuthProvider>();

      final user = authProvider.user;

      if (user == null) {
        return;
      }

      final health = await _profileService.getHealthInformation(
        userId: user.uid,
      );
      final profileDetails = await _profileService.getProfileDetails(
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _healthInformation = health;
        _phoneNumber = profileDetails?['phoneNumber'] as String?;
        _profilePhotoUrl = profileDetails?['photoUrl'] as String?;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load health information.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHealth = false;
        });
      }
    }
  }

  Future<void> _openHealthInformation() async {
    await Navigator.pushNamed(context, AppRoutes.healthInformation);

    if (!mounted) {
      return;
    }

    await _loadHealthInformation();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            color: Colors.redAccent,
            size: 28,
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to log out of your account?',
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(
            bottom: 16,
            left: 16,
            right: 16,
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(110, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(110, 44),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    final success = await context.read<AuthProvider>().logout();

    if (!mounted || !success) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.auth, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final user = authProvider.user;

    final name = user?.displayName ?? 'User';

    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHealthInformation,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // =================================================
                // PROFILE HEADER
                // =================================================
                ProfileHeader(
                  name: name,
                  email: email,
                  photoUrl: _profilePhotoUrl ?? user?.photoUrl,
                  phoneNumber: _phoneNumber,
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profileInformation,
                    ).then((_) {
                      if (mounted) {
                        _loadHealthInformation();
                      }
                    });
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Profile photo, name, email, and mobile',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.profileInformation,
                          ).then((_) {
                            if (mounted) {
                              _loadHealthInformation();
                            }
                          });
                        },
                      ),
                      const Divider(height: 1, indent: 74),
                      ProfileMenuTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.changePassword,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // HEALTH INFORMATION
                // =================================================
                if (_isLoadingHealth)
                  const Center(child: CircularProgressIndicator())
                else
                  HealthInfoSection(
                    healthInformation: _healthInformation,
                    onTap: _openHealthInformation,
                  ),

                const SizedBox(height: 24),

                // =================================================
                // MEDICAL CARD
                // =================================================
                const Text(
                  'Medical Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.badge_outlined,
                        title: 'Medical Card',
                        subtitle: 'Share or download a quick medical summary',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.medicalCard);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // EMERGENCY CONTACT
                // =================================================
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.contact_emergency_outlined,
                        title: 'Personal Contacts',
                        subtitle:
                            'Add, edit, call, and remove trusted contacts',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.emergencyContacts,
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 74),
                      // ProfileMenuTile(
                      //   icon: Icons.local_hospital_outlined,
                      //   title: 'Doctor Contacts',
                      //   subtitle: 'Keep doctors and clinics ready to call',
                      //   onTap: () {
                      //     Navigator.pushNamed(
                      //       context,
                      //       AppRoutes.emergencyContacts,
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // SETTINGS
                // =================================================
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Theme, privacy, security, and about',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // LOGOUT
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: authProvider.isLoading ? null : _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD92D20),
                      side: const BorderSide(color: Color(0xFFD92D20)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
