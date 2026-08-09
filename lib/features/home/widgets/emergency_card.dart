import 'package:flutter/material.dart';

class HomeEmergencyCard extends StatelessWidget {
  const HomeEmergencyCard({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD5D5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE0E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency,
              color: Color(0xFFD32F2F),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Get quick access to emergency assistance.',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor:
                  const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(
              Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}