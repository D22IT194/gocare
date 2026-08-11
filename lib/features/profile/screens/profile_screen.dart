import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../authentication/providers/auth_provider.dart';
import '../models/health_information.dart';
import '../services/profile_service.dart';
import '../widgets/health_info_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  HealthInformation? _healthInformation;

  String? _profileName;
  String? _phoneNumber;
  String? _profilePhotoUrl;

  bool _isLoadingHealth = true;
  bool _isUploadingProfilePhoto = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadProfileData();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfileData() async {
    if (mounted) {
      setState(() {
        _isLoadingHealth = true;
      });
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoadingHealth = false;
        });

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

        _profileName = profileDetails?['name']?.toString();

        _phoneNumber = profileDetails?['phoneNumber']?.toString();

        _profilePhotoUrl = profileDetails?['photoUrl']?.toString();

        _isLoadingHealth = false;
      });
    } catch (e) {
      debugPrint('PROFILE LOAD ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingHealth = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load profile information.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await _loadProfileData();
  }

  // ============================================================
  // PROFILE EDIT
  // ============================================================

  Future<void> _openProfileInformation() async {
    await Navigator.pushNamed(context, AppRoutes.profileInformation);

    if (!mounted) {
      return;
    }

    await _loadProfileData();
  }

  // ============================================================
  // HEALTH INFORMATION
  // ============================================================

  Future<void> _openHealthInformation() async {
    await Navigator.pushNamed(context, AppRoutes.healthInformation);

    if (!mounted) {
      return;
    }

    await _loadProfileData();
  }

  // ============================================================
  // PROFILE PHOTO TAP
  // ============================================================

  Future<void> _handleProfilePhotoTap() async {
    if (_isUploadingProfilePhoto) {
      return;
    }

    final photoUrl = _profilePhotoUrl?.trim();

    if (photoUrl != null && photoUrl.isNotEmpty) {
      _viewProfilePhoto(photoUrl);
      return;
    }

    await _showAddProfilePhotoSheet();
  }

  // ============================================================
  // VIEW PROFILE PHOTO
  // ============================================================

  void _viewProfilePhoto(String photoUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D2939),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 50,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Unable to load photo',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ADD PHOTO BOTTOM SHEET
  // ============================================================

  Future<void> _showAddProfilePhotoSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                // Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Color(0xFF1976D2),
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Profile Photo',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose how you want to add your photo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ==================================================
                // CAMERA
                // ==================================================
                _PhotoOptionTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take a Photo',
                  subtitle: 'Open camera and take a new profile photo',
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await Future.delayed(const Duration(milliseconds: 250));

                    await _pickProfilePhoto(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // GALLERY
                // ==================================================
                _PhotoOptionTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Select a photo from your device',
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await Future.delayed(const Duration(milliseconds: 250));

                    await _pickProfilePhoto(ImageSource.gallery);
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  'Supported image: JPG, JPEG, PNG',
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
  // PICK PROFILE PHOTO
  // ============================================================

  Future<void> _pickProfilePhoto(ImageSource source) async {
    if (_isUploadingProfilePhoto) {
      return;
    }

    try {
      debugPrint('OPEN IMAGE PICKER: $source');

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile == null) {
        debugPrint('USER CANCELLED IMAGE PICKER');
        return;
      }

      debugPrint('PHOTO SELECTED: ${pickedFile.path}');

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingProfilePhoto = true;
      });

      final user = context.read<AuthProvider>().user;

      if (user == null) {
        throw Exception('User is not logged in.');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();

        await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        await storageRef.putFile(
          File(pickedFile.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final downloadUrl = await storageRef.getDownloadURL();

      await _profileService.saveProfileDetails(
        userId: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        phoneNumber: _phoneNumber ?? '',
        photoUrl: downloadUrl,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profilePhotoUrl = downloadUrl;
        _isUploadingProfilePhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('PROFILE PHOTO ERROR: $e');

      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingProfilePhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select/upload photo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) {
        return _LogoutBottomSheet(
          onCancel: () {
            Navigator.pop(dialogContext, false);
          },
          onConfirm: () {
            Navigator.pop(dialogContext, true);
          },
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

  // ============================================================
  // PROFILE COMPLETION
  // ============================================================

  double _profileCompletion({required String name, required String email}) {
    int completed = 0;

    if (name.trim().isNotEmpty && name.trim() != 'User') {
      completed++;
    }

    if (email.trim().isNotEmpty) {
      completed++;
    }

    if (_phoneNumber?.trim().isNotEmpty == true) {
      completed++;
    }

    if (_profilePhotoUrl?.trim().isNotEmpty == true) {
      completed++;
    }

    if (_healthInformation != null) {
      completed++;
    }

    return completed / 5;
  }

  String _completionText(double value) {
    final percentage = (value * 100).round();

    if (percentage >= 100) {
      return 'Profile complete';
    }

    return '$percentage% profile completed';
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildProfileAvatar({
    required String name,
    required String? photoUrl,
  }) {
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    final firstLetter = name.trim().isEmpty
        ? 'U'
        : name.trim()[0].toUpperCase();

    return GestureDetector(
      onTap: _handleProfilePhotoTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: hasPhoto
                  ? Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _AvatarPlaceholder(letter: firstLetter);
                      },
                    )
                  : _AvatarPlaceholder(letter: firstLetter),
            ),
          ),

          // Camera / edit indicator
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                hasPhoto
                    ? Icons.visibility_outlined
                    : Icons.camera_alt_outlined,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),

          // Upload loader
          if (_isUploadingProfilePhoto)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final user = authProvider.user;

    final authName = user?.displayName?.trim() ?? '';
    final firestoreName = _profileName?.trim() ?? '';

    final name = firestoreName.isNotEmpty
        ? firestoreName
        : authName.isNotEmpty
        ? authName
        : 'User';

    final email = user?.email?.trim() ?? '';

    final photoUrl = _profilePhotoUrl?.trim();

    final completion = _profileCompletion(name: name, email: email);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF7F9FC),
        centerTitle: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E7EC)),
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 21,
                color: Color(0xFF344054),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF1976D2),
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // PROFILE HEADER
                // ==================================================
                _ProfileHeaderCard(
                  avatar: _buildProfileAvatar(name: name, photoUrl: photoUrl),
                  name: name,
                  email: email,
                  phone: _phoneNumber,
                  onEdit: _openProfileInformation,
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PROFILE COMPLETION
                // ==================================================
                _ProfileCompletionCard(
                  value: completion,
                  title: _completionText(completion),
                  onTap: _openProfileInformation,
                ),

                const SizedBox(height: 28),

                // ==================================================
                // ACCOUNT
                // ==================================================
                const _SectionTitle(
                  title: 'Account',
                  subtitle: 'Manage your personal information',
                ),

                const SizedBox(height: 12),

                _MenuCard(
                  children: [
                    _ProfileActionTile(
                      icon: Icons.manage_accounts_outlined,
                      iconColor: const Color(0xFF1976D2),
                      title: 'Edit Profile',
                      subtitle: 'Photo, name, email and mobile',
                      onTap: _openProfileInformation,
                    ),
                    const _CardDivider(),
                    _ProfileActionTile(
                      icon: Icons.lock_outline,
                      iconColor: const Color(0xFF7F56D9),
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.changePassword);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // HEALTH
                // ==================================================
                const _SectionTitle(
                  title: 'Health',
                  subtitle: 'Keep your important health information updated',
                ),

                const SizedBox(height: 12),

                if (_isLoadingHealth)
                  const _LoadingHealthCard()
                else
                  HealthInfoSection(
                    healthInformation: _healthInformation,
                    onTap: _openHealthInformation,
                  ),

                const SizedBox(height: 28),

                // ==================================================
                // MEDICAL CARD
                // ==================================================
                const _SectionTitle(
                  title: 'Medical Card',
                  subtitle:
                      'Quick access to your emergency medical information',
                ),

                const SizedBox(height: 12),

                _MedicalCardAction(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.medicalCard);
                  },
                ),

                const SizedBox(height: 28),

                // ==================================================
                // EMERGENCY CONTACTS
                // ==================================================
                const _SectionTitle(
                  title: 'Emergency Contacts',
                  subtitle: 'People you can quickly call in an emergency',
                ),

                const SizedBox(height: 12),

                _EmergencyContactsAction(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                  },
                ),

                const SizedBox(height: 28),

                // ==================================================
                // SETTINGS
                // ==================================================
                const _SectionTitle(
                  title: 'Settings',
                  subtitle: 'Customize your GoCare experience',
                ),

                const SizedBox(height: 12),

                _MenuCard(
                  children: [
                    _ProfileActionTile(
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xFF667085),
                      title: 'Settings',
                      subtitle: 'Theme, privacy, security and about',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // LOGOUT
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: authProvider.isLoading ? null : _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(
                      authProvider.isLoading ? 'Logging out...' : 'Logout',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD92D20),
                      side: const BorderSide(color: Color(0xFFF04438)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Center(
                  child: Text(
                    'GoCare • Your health, always within reach',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF98A2B3)),
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

// ============================================================
// PROFILE HEADER
// ============================================================

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.avatar,
    required this.name,
    required this.email,
    required this.phone,
    required this.onEdit,
  });

  final Widget avatar;
  final String name;
  final String email;
  final String? phone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF00A896)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          avatar,

          const SizedBox(height: 14),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          if (email.isNotEmpty)
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),

          if (phone?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              phone!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 17),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
                backgroundColor: Colors.white.withValues(alpha: 0.10),
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

// ============================================================
// AVATAR PLACEHOLDER
// ============================================================

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF4FF),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }
}

// ============================================================
// PHOTO OPTION
// ============================================================

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF1976D2), size: 25),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
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

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.35,
            color: Color(0xFF667085),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MENU CARD
// ============================================================

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ============================================================
// ACTION TILE
// ============================================================

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
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
}

// ============================================================
// DIVIDER
// ============================================================

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 74,
      endIndent: 16,
      color: Color(0xFFEAECF0),
    );
  }
}

// ============================================================
// PROFILE COMPLETION
// ============================================================

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({
    required this.value,
    required this.title,
    required this.onTap,
  });

  final double value;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD6E9FF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF1976D2),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Complete your profile for a better GoCare experience.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: onTap,
                child: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MEDICAL CARD
// ============================================================

class _MedicalCardAction extends StatelessWidget {
  const _MedicalCardAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1976D2), Color(0xFF00A896)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GoCare Medical Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View, share, download or print your medical summary',
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMERGENCY CONTACTS
// ============================================================

class _EmergencyContactsAction extends StatelessWidget {
  const _EmergencyContactsAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD6D2)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDEA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.contact_emergency_outlined,
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
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Quickly call your family, friends or doctors when needed',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
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

// ============================================================
// LOADING HEALTH
// ============================================================

class _LoadingHealthCard extends StatelessWidget {
  const _LoadingHealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }
}

// ============================================================
// LOGOUT BOTTOM SHEET
// ============================================================

class _LogoutBottomSheet extends StatelessWidget {
  const _LogoutBottomSheet({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE4E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFD92D20),
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Logout from GoCare?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'You can sign in again anytime to access your profile, health information and emergency contacts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF667085),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.logout_rounded, size: 19),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
  }
}
