import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.imageProvider,
    this.phoneNumber,
    this.onEdit,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final ImageProvider? imageProvider;
  final String? phoneNumber;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();

    final firstLetter = trimmedName.isNotEmpty
        ? trimmedName[0].toUpperCase()
        : 'U';
    final resolvedImageProvider = imageProvider ?? _profileImageProvider();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6E9FF)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                backgroundImage: resolvedImageProvider,
                child:
                    resolvedImageProvider == null
                    ? Text(
                        firstLetter,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1976D2),
                        ),
                      )
                    : null,
              ),
              if (onEdit != null)
                Material(
                  color: const Color(0xFF1976D2),
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(18),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            trimmedName.isNotEmpty ? trimmedName : 'User',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
          ),

          if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              phoneNumber!.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
            ),
          ],
        ],
      ),
    );
  }

  ImageProvider? _profileImageProvider() {
    final value = photoUrl?.trim() ?? '';

    if (value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }

    if (!kIsWeb && File(value).existsSync()) {
      return FileImage(File(value));
    }

    return null;
  }
}
