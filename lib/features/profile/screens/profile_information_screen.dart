import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../authentication/providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../widgets/profile_header.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  XFile? _selectedPhoto;
  String? _photoUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _photoUrl = user?.photoUrl;

    _loadSavedProfileDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfileDetails() async {
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      return;
    }

    final details = await _profileService.getProfileDetails(userId: user.uid);

    if (!mounted || details == null) {
      return;
    }

    setState(() {
      _phoneController.text =
          details['phoneNumber'] as String? ?? _phoneController.text;
      _photoUrl = details['photoUrl'] as String? ?? _photoUrl;
    });
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1000,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedPhoto = picked;
    });
  }

  Future<String?> _saveSelectedPhoto(String userId) async {
    final photo = _selectedPhoto;

    if (photo == null) {
      return _photoUrl;
    }

    setState(() {
      _isUploadingPhoto = true;
    });

    final localPhotoPath = await _savePhotoLocally(photo, userId);

    try {
      final reference = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('$userId-${DateTime.now().millisecondsSinceEpoch}.jpg');

      if (kIsWeb) {
        await reference.putData(
          await photo.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        await reference.putFile(
          File(photo.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      return reference.getDownloadURL();
    } catch (_) {
      return localPhotoPath;
    }
  }

  Future<String> _savePhotoLocally(
    XFile photo,
    String userId,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final profileDirectory = Directory('${directory.path}/profile_photos');

    if (!await profileDirectory.exists()) {
      await profileDirectory.create(recursive: true);
    }

    final localFile = File('${profileDirectory.path}/$userId.jpg');

    if (kIsWeb) {
      await localFile.writeAsBytes(await photo.readAsBytes());
    } else {
      await File(photo.path).copy(localFile.path);
    }

    return localFile.path;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return;
    }

    String? uploadedPhotoUrl;

    try {
      uploadedPhotoUrl = await _saveSelectedPhoto(user.uid);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingPhoto = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to upload profile photo.')),
      );

      return;
    }

    final success = await authProvider.updateProfile(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      photoUrl:
          uploadedPhotoUrl != null &&
              (uploadedPhotoUrl.startsWith('http://') ||
                  uploadedPhotoUrl.startsWith('https://'))
          ? uploadedPhotoUrl
          : '',
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      await _profileService.saveProfileDetails(
        userId: user.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        photoUrl: uploadedPhotoUrl,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _photoUrl = uploadedPhotoUrl;
      _selectedPhoto = null;
      _isUploadingPhoto = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile updated successfully.'
              : authProvider.errorMessage ?? 'Unable to update profile.',
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Information')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  name: _nameController.text.isNotEmpty
                      ? _nameController.text
                      : user?.displayName ?? 'User',
                  email: _emailController.text.isNotEmpty
                      ? _emailController.text
                      : user?.email ?? '',
                  photoUrl: _photoUrl,
                  imageProvider: _selectedPhoto == null
                      ? null
                      : FileImage(File(_selectedPhoto!.path)),
                  phoneNumber: _phoneController.text,
                ),
                const SizedBox(height: 18),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _isUploadingPhoto ? null : _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _selectedPhoto == null
                          ? 'Choose photo from gallery'
                          : 'Change selected photo',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }

                    return null;
                  },
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Mobile number is required';
                    }

                    if (phone.length < 8) {
                      return 'Enter a valid mobile number';
                    }

                    return null;
                  },
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Email is required';
                    }

                    if (!email.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: authProvider.isLoading || _isUploadingPhoto
                      ? null
                      : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _isUploadingPhoto ? 'Uploading photo...' : 'Save profile',
                  ),
                ),
                const SizedBox(height: 12),
                // OutlinedButton.icon(
                //   onPressed: () {
                //     Navigator.pushNamed(context, AppRoutes.changePassword);
                //   },
                //   icon: const Icon(Icons.lock_outline),
                //   label: const Text('Change password'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
