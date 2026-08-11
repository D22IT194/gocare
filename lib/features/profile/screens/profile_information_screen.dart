import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../authentication/providers/auth_provider.dart';
import '../services/profile_service.dart';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends State<ProfileInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProfileService _profileService = ProfileService();

  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  XFile? _selectedPhoto;

  Uint8List? _selectedPhotoBytes;

  String? _photoUrl;

  bool _isUploadingPhoto = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;

    _nameController = TextEditingController(
      text: user?.displayName ?? '',
    );

    _emailController = TextEditingController(
      text: user?.email ?? '',
    );

    _phoneController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );

    _photoUrl = user?.photoUrl;

    _loadSavedProfileDetails();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadSavedProfileDetails() async {
    try {
      final user = context.read<AuthProvider>().user;

      if (user == null) {
        return;
      }

      final details =
          await _profileService.getProfileDetails(
        userId: user.uid,
      );

      if (!mounted || details == null) {
        return;
      }

      setState(() {
        _phoneController.text =
            details['phoneNumber'] as String? ??
                _phoneController.text;

        _photoUrl =
            details['photoUrl'] as String? ??
                _photoUrl;
      });
    } catch (e) {
      debugPrint(
        'LOAD PROFILE DETAILS ERROR: $e',
      );
    }
  }

  // ============================================================
  // CURRENT PHOTO EXISTS
  // ============================================================

  bool get _hasPhoto {
    return _selectedPhotoBytes != null ||
        (_photoUrl != null &&
            _photoUrl!.trim().isNotEmpty);
  }

  // ============================================================
  // PHOTO IMAGE
  // ============================================================

  Widget _buildProfilePhoto({
    double size = 128,
  }) {
    // ----------------------------------------------------------
    // NEW CROPPED PHOTO
    // ----------------------------------------------------------

    if (_selectedPhotoBytes != null &&
        _selectedPhotoBytes!.isNotEmpty) {
      return ClipOval(
        child: Image.memory(
          _selectedPhotoBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return _photoPlaceholder(size);
          },
        ),
      );
    }

    // ----------------------------------------------------------
    // FIREBASE PHOTO
    // ----------------------------------------------------------

    if (_photoUrl != null &&
        _photoUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder:
              (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return _photoLoading(size);
          },
          errorBuilder:
              (context, error, stackTrace) {
            return _photoPlaceholder(size);
          },
        ),
      );
    }

    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    return _photoPlaceholder(size);
  }

  // ============================================================
  // PHOTO PLACEHOLDER
  // ============================================================

  Widget _photoPlaceholder(
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEAF4FF),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        size: 62,
        color: Color(0xFF1976D2),
      ),
    );
  }

  // ============================================================
  // PHOTO LOADING
  // ============================================================

  Widget _photoLoading(
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEAF4FF),
      ),
      child: const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF1976D2),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE PHOTO FRAME
  // ============================================================

  Widget _buildProfilePhotoFrame() {
    return GestureDetector(
      onTap: _isUploadingPhoto
          ? null
          : _showPhotoOptions,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ======================================================
          // OUTER FRAME
          // ======================================================

          Container(
            width: 146,
            height: 146,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF1976D2),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: _buildProfilePhoto(
              size: 132,
            ),
          ),

          // ======================================================
          // CAMERA BUTTON
          // ======================================================

          Positioned(
            right: 0,
            bottom: 4,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1976D2),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),

          // ======================================================
          // UPLOADING OVERLAY
          // ======================================================

          if (_isUploadingPhoto)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(
                    alpha: 0.45,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PHOTO OPTIONS
  // ============================================================

  Future<void> _showPhotoOptions() async {
    if (_isUploadingPhoto) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              28,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                // Header
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.account_circle_outlined,
                        color: Color(0xFF1976D2),
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Photo',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(0xFF172B4D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage your profile picture',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // VIEW PHOTO
                // ==================================================

                if (_hasPhoto)
                  _PhotoOptionTile(
                    icon: Icons.visibility_outlined,
                    title: 'View Photo',
                    subtitle:
                        'Preview your current profile photo',
                    onTap: () {
                      Navigator.pop(sheetContext);

                      Future.delayed(
                        const Duration(
                          milliseconds: 200,
                        ),
                        () {
                          if (mounted) {
                            _showFullPhotoPreview();
                          }
                        },
                      );
                    },
                  ),

                if (_hasPhoto)
                  const SizedBox(height: 10),

                // ==================================================
                // CAMERA
                // ==================================================

                _PhotoOptionTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take a Photo',
                  subtitle:
                      'Use your camera to take a new photo',
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await Future.delayed(
                      const Duration(
                        milliseconds: 250,
                      ),
                    );

                    await _pickPhoto(
                      ImageSource.camera,
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // GALLERY
                // ==================================================

                _PhotoOptionTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle:
                      'Select a photo from your device',
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    await Future.delayed(
                      const Duration(
                        milliseconds: 250,
                      ),
                    );

                    await _pickPhoto(
                      ImageSource.gallery,
                    );
                  },
                ),

                // ==================================================
                // REMOVE SELECTED PHOTO
                // ==================================================

                if (_selectedPhoto != null) ...[
                  const SizedBox(height: 10),

                  _PhotoOptionTile(
                    icon: Icons.close_rounded,
                    title: 'Remove Selected Photo',
                    subtitle:
                        'Cancel the new photo before saving',
                    iconColor:
                        const Color(0xFFD92D20),
                    backgroundColor:
                        const Color(0xFFFFF1F0),
                    onTap: () {
                      Navigator.pop(sheetContext);

                      setState(() {
                        _selectedPhoto = null;
                        _selectedPhotoBytes = null;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 14),

                const Text(
                  'JPG, JPEG and PNG images are supported',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FULL PHOTO PREVIEW
  // ============================================================

  Future<void> _showFullPhotoPreview() async {
    if (!_hasPhoto) {
      return;
    }

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.92,
      ),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 30,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ==================================================
              // PHOTO
              // ==================================================

              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(22),
                  child: _buildPreviewImage(),
                ),
              ),

              // ==================================================
              // CLOSE
              // ==================================================

              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(
                    alpha: 0.55,
                  ),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                      );
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
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
  // PREVIEW IMAGE
  // ============================================================

  Widget _buildPreviewImage() {
    if (_selectedPhotoBytes != null &&
        _selectedPhotoBytes!.isNotEmpty) {
      return Image.memory(
        _selectedPhotoBytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    }

    if (_photoUrl != null &&
        _photoUrl!.trim().isNotEmpty) {
      return Image.network(
        _photoUrl!,
        fit: BoxFit.contain,
      );
    }

    return const SizedBox.shrink();
  }




  // ============================================================
  // PICK PHOTO
  // ============================================================

Future<void> _pickPhoto(ImageSource source) async {
    if (_isUploadingPhoto) {
      return;
    }

    try {
      debugPrint('OPEN IMAGE PICKER: $source');

      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (picked == null) {
        debugPrint('USER CANCELLED IMAGE PICKER');
        return;
      }

      final bytes = await picked.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('Selected image is empty.');
      }

      if (!mounted) {
        return;
      }

      final Uint8List? cropped =
          await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          builder: (_) => ProfilePhotoCropScreen(
            imageBytes: bytes,
          ),
        ),
      );

      if (cropped == null || cropped.isEmpty) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedPhoto = picked;
        _selectedPhotoBytes = cropped;
      });
    } catch (e, stackTrace) {
      debugPrint('PROFILE PHOTO PICK ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Unable to open camera.'
                : 'Unable to select photo from gallery.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  // ============================================================
  // SELECTED PHOTO PREVIEW
  // ============================================================

  Future<void> _showSelectedPhotoPreview() async {
    if (_selectedPhoto == null) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (previewContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              25,
            ),
            decoration:
                const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFD0D5DD,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Preview Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'This photo will be placed inside your profile frame.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Color(0xFF667085),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // FRAME PREVIEW
                // ==================================================

                Container(
                  width: 190,
                  height: 190,
                  padding:
                      const EdgeInsets.all(6),
                  decoration:
                      BoxDecoration(
                    shape:
                        BoxShape.circle,
                    color: Colors.white,
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFF1976D2,
                      ),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black
                                .withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 25,
                        offset:
                            const Offset(
                          0,
                          10,
                        ),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        _buildSelectedPhotoPreview(
                      size: 178,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child:
                          OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            previewContext,
                          );

                          setState(() {
                            _selectedPhoto = null;
                            _selectedPhotoBytes = null;
                          });
                        },
                        child: const Text(
                          'Cancel',
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            previewContext,
                          );
                        },
                        icon: const Icon(
                          Icons.check_rounded,
                        ),
                        label: const Text(
                          'Use Photo',
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF1976D2,
                          ),
                          foregroundColor:
                              Colors.white,
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
  }

  // ============================================================
  // SELECTED PHOTO PREVIEW IMAGE
  // ============================================================

  Widget _buildSelectedPhotoPreview({
    required double size,
  }) {
    if (_selectedPhotoBytes == null ||
        _selectedPhotoBytes!.isEmpty) {
      return _photoPlaceholder(size);
    }

    return Image.memory(
      _selectedPhotoBytes!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return _photoPlaceholder(size);
      },
    );
  }


  // ============================================================
  // SAVE SELECTED PHOTO
  // ============================================================

  Future<String?> _saveSelectedPhoto(
    String userId,
  ) async {
    final bytes = _selectedPhotoBytes;

    if (bytes == null || bytes.isEmpty) {
      return _photoUrl;
    }

    if (mounted) {
      setState(() {
        _isUploadingPhoto = true;
      });
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$userId.jpg');

      debugPrint('========================================');
      debugPrint('PROFILE PHOTO UPLOAD');
      debugPrint('USER ID: $userId');
      debugPrint('PATH: ${storageRef.fullPath}');
      debugPrint('BYTES: ${bytes.length}');

      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=31536000',
        ),
      );

      final downloadUrl =
          await storageRef.getDownloadURL();

      debugPrint('PROFILE PHOTO UPLOAD SUCCESS');
      debugPrint('PROFILE PHOTO URL: $downloadUrl');
      debugPrint('========================================');

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('PROFILE PHOTO FIREBASE ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('PROFILE PHOTO UPLOAD ERROR: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }


  // ============================================================
  // SAVE PROFILE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_isUploadingPhoto) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('User is not logged in.'),
        ),
      );

      return;
    }

    String? uploadedPhotoUrl;

    try {
      uploadedPhotoUrl =
          await _saveSelectedPhoto(
        user.uid,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to upload profile photo: $e',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ==========================================================
    // UPDATE AUTH PROFILE
    // ==========================================================

    final success =
        await authProvider.updateProfile(
      displayName:
          _nameController.text.trim(),
      email:
          _emailController.text.trim(),
      photoUrl:
          uploadedPhotoUrl != null &&
                  (uploadedPhotoUrl
                          .startsWith(
                              'http://') ||
                      uploadedPhotoUrl
                          .startsWith(
                              'https://'))
              ? uploadedPhotoUrl
              : '',
      phoneNumber:
          _phoneController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // SAVE TO FIRESTORE
    // ==========================================================

    if (success) {
      try {
        await _profileService
            .saveProfileDetails(
          userId: user.uid,
          name:
              _nameController.text.trim(),
          email:
              _emailController.text.trim(),
          phoneNumber:
              _phoneController.text.trim(),
          photoUrl: uploadedPhotoUrl,
        );
      } catch (e) {
        debugPrint(
          'SAVE PROFILE FIRESTORE ERROR: $e',
        );
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (uploadedPhotoUrl != null &&
          uploadedPhotoUrl
              .trim()
              .isNotEmpty) {
        _photoUrl =
            uploadedPhotoUrl;
      }

      _selectedPhoto = null;
      _selectedPhotoBytes = null;

      _isUploadingPhoto = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully.'
              : authProvider.errorMessage ??
                  'Unable to update profile.',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final authProvider =
        context.watch<AuthProvider>();

    final user = authProvider.user;

    final displayName =
        _nameController.text
                .trim()
                .isNotEmpty
            ? _nameController.text
                .trim()
            : user?.displayName ??
                'User';

    final email =
        _emailController.text
                .trim()
                .isNotEmpty
            ? _emailController.text
                .trim()
            : user?.email ?? '';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: const Text(
          'Profile Information',
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                // ==================================================
                // PROFILE PHOTO FRAME
                // ==================================================

                Center(
                  child:
                      _buildProfilePhotoFrame(),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PHOTO TEXT
                // ==================================================

                Center(
                  child: Column(
                    children: [
                      Text(
                        _hasPhoto
                            ? 'Tap photo to view or change'
                            : 'Add your profile photo',
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              Color(
                            0xFF172B4D,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      const Text(
                        'Your photo will appear in this frame',
                        style:
                            TextStyle(
                          fontSize: 11,
                          color:
                              Color(
                            0xFF667085,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // NAME
                // ==================================================

                TextFormField(
                  controller:
                      _nameController,

                  textCapitalization:
                      TextCapitalization
                          .words,

                  decoration:
                      const InputDecoration(
                    labelText: 'Name',
                    prefixIcon:
                        Icon(
                      Icons
                          .person_outline,
                    ),
                  ),

                  validator: (value) {
                    if (value ==
                            null ||
                        value
                            .trim()
                            .isEmpty) {
                      return
                          'Name is required';
                    }

                    return null;
                  },

                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // PHONE
                // ==================================================

                TextFormField(
                  controller:
                      _phoneController,

                  keyboardType:
                      TextInputType.phone,

                  decoration:
                      const InputDecoration(
                    labelText:
                        'Mobile number',
                    prefixIcon:
                        Icon(
                      Icons
                          .phone_outlined,
                    ),
                  ),

                  validator: (value) {
                    final phone =
                        value?.trim() ??
                            '';

                    if (phone.isEmpty) {
                      return
                          'Mobile number is required';
                    }

                    if (phone.length <
                        8) {
                      return
                          'Enter a valid mobile number';
                    }

                    return null;
                  },

                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                // ==================================================
                // EMAIL
                // ==================================================

                TextFormField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(
                      Icons
                          .email_outlined,
                    ),
                  ),

                  validator: (value) {
                    final email =
                        value?.trim() ??
                            '';

                    if (email.isEmpty) {
                      return
                          'Email is required';
                    }

                    if (!email.contains(
                      '@',
                    )) {
                      return
                          'Enter a valid email';
                    }

                    return null;
                  },

                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(
                  height: 24,
                ),

                // ==================================================
                // SAVE BUTTON
                // ==================================================

                SizedBox(
                  width:
                      double.infinity,
                  height: 54,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        authProvider
                                    .isLoading ||
                                _isUploadingPhoto
                            ? null
                            : _save,

                    icon:
                        _isUploadingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2.3,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .save_outlined,
                              ),

                    label: Text(
                      _isUploadingPhoto
                          ? 'Uploading photo...'
                          : authProvider
                                  .isLoading
                              ? 'Saving profile...'
                              : 'Save Profile',
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF1976D2,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // INFORMATION CARD
                // ==================================================

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF8FAFC,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFE4E7EC,
                      ),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Icon(
                        Icons
                            .info_outline,
                        size: 19,
                        color:
                            Color(
                          0xFF667085,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap your profile photo to view it, take a new photo, or choose one from your gallery. Save Profile to upload the selected photo.',
                          style:
                              TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color:
                                Color(
                              0xFF667085,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ================================================================
// PROFILE PHOTO CROP SCREEN
// ================================================================

class ProfilePhotoCropScreen extends StatefulWidget {
  const ProfilePhotoCropScreen({
    super.key,
    required this.imageBytes,
  });

  final Uint8List imageBytes;

  @override
  State<ProfilePhotoCropScreen> createState() =>
      _ProfilePhotoCropScreenState();
}

class _ProfilePhotoCropScreenState
    extends State<ProfilePhotoCropScreen> {
  final CropController _cropController = CropController();

  bool _circleMode = true;
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Set Profile Photo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Crop(
                    image: widget.imageBytes,
                    controller: _cropController,
                    aspectRatio: 1,
                    withCircleUi: _circleMode,
                    interactive: true,
                    fixCropRect: false,
                    maskColor: Colors.black.withValues(alpha: 0.72),
                    baseColor: Colors.black,
                    radius: _circleMode ? 1000 : 20,
                    onCropped: _onCropped,
                  ),
                ),
              ),
            ),
            const Text(
              'Pinch to zoom • Drag to position',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _CropModeButton(
                      icon: Icons.circle_outlined,
                      label: 'Circle',
                      selected: _circleMode,
                      onTap: () {
                        setState(() => _circleMode = true);
                        _cropController.withCircleUi = true;
                        _cropController.aspectRatio = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CropModeButton(
                      icon: Icons.crop_square_rounded,
                      label: 'Square',
                      selected: !_circleMode,
                      onTap: () {
                        setState(() => _circleMode = false);
                        _cropController.withCircleUi = false;
                        _cropController.aspectRatio = 1;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isCropping ? null : _crop,
                  icon: _isCropping
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _isCropping ? 'Processing...' : 'Use Photo',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _crop() {
    if (_isCropping) return;

    setState(() => _isCropping = true);

    if (_circleMode) {
      _cropController.cropCircle();
    } else {
      _cropController.crop();
    }
  }

  void _onCropped(CropResult result) {
    if (!mounted) return;

    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.pop(context, croppedImage);
        break;
      case CropFailure(:final cause):
        setState(() => _isCropping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to crop image: $cause'),
          ),
        );
        break;
    }
  }
}

class _CropModeButton extends StatelessWidget {
  const _CropModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF1976D2)
          : const Color(0xFF1F1F1F),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PHOTO OPTION TILE
// ================================================================

class _PhotoOptionTile
    extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor =
        const Color(0xFF1976D2),
    this.backgroundColor =
        const Color(0xFFF8FAFC),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: backgroundColor,
      borderRadius:
          BorderRadius.circular(17),

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(17),

        child: Padding(
          padding:
              const EdgeInsets.all(15),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                    BoxDecoration(
                  color: iconColor
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFF172B4D,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color:
                            Color(
                          0xFF667085,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    Color(0xFF98A2B3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}