import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
            (index) {
          final bool isActive = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 28 : 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFD0D7DE),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}