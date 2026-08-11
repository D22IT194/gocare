import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

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

  bool _isCropping = false;
  bool _circleMode = true;

  Uint8List? _croppedImage;

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
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Done',
            onPressed: _isCropping
                ? null
                : () {
                    setState(() {
                      _isCropping = true;
                    });

                    _cropController.crop();
                  },
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Crop(
                      image: widget.imageBytes,
                      controller: _cropController,

                      aspectRatio: 1,

                      withCircleUi: _circleMode,

                      maskColor:
                          Colors.black.withValues(alpha: 0.72),

                      baseColor: Colors.black,

                      radius: _circleMode ? 999 : 18,

                      onCropped: (result) {
                        if (!mounted) {
                          return;
                        }

                        setState(() {
                          _isCropping = false;
                        });

                        switch (result) {
                          case CropSuccess(:final croppedImage):
                            Navigator.of(context).pop(
                              croppedImage,
                            );

                          case CropFailure(:final cause):
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to crop image: $cause',
                                ),
                              ),
                            );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            _buildBottomControls(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: [
          const Text(
            'Pinch to zoom • Drag to position',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _FrameButton(
                  icon: Icons.circle_outlined,
                  title: 'Circle',
                  selected: _circleMode,
                  onTap: () {
                    setState(() {
                      _circleMode = true;
                    });

                    _cropController.aspectRatio = 1;
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _FrameButton(
                  icon: Icons.crop_square_rounded,
                  title: 'Rectangle',
                  selected: !_circleMode,
                  onTap: () {
                    setState(() {
                      _circleMode = false;
                    });

                    _cropController.aspectRatio = 1;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isCropping
                  ? null
                  : () {
                      setState(() {
                        _isCropping = true;
                      });

                      _cropController.crop();
                    },
              icon: _isCropping
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.check_rounded,
                    ),
              label: Text(
                _isCropping
                    ? 'Processing...'
                    : 'Use Photo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameButton extends StatelessWidget {
  const _FrameButton({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                title,
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