import 'package:flutter/material.dart';

import '../models/onboarding_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel page;

  const OnboardingPage({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),

            Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              constraints: const BoxConstraints(
                maxWidth: 280,
                maxHeight: 280,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.08),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                page.icon,
                style: const TextStyle(
                  fontSize: 90,
                ),
              ),
            ),

            const Spacer(),

            Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF667085),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}