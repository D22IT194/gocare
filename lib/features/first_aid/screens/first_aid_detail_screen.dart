import 'package:flutter/material.dart';

import '../models/first_aid_model.dart';

class FirstAidDetailScreen extends StatelessWidget {
  const FirstAidDetailScreen({
    super.key,
    required this.item,
  });

  final FirstAidModel item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'First Aid Guide',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FF),
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    item.icon,
                    style: const TextStyle(
                      fontSize: 64,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(
              icon: Icons.check_circle_outline,
              title: 'What to do',
            ),

            const SizedBox(height: 12),

            ...List.generate(
              item.steps.length,
              (index) {
                return _StepItem(
                  number: index + 1,
                  text: item.steps[index],
                );
              },
            ),

            const SizedBox(height: 24),

            _SectionTitle(
              icon: Icons.cancel_outlined,
              title: 'Do not',
            ),

            const SizedBox(height: 12),

            ...item.doNot.map(
              (text) => _DoNotItem(
                text: text,
              ),
            ),

            const SizedBox(height: 24),

            _SectionTitle(
              icon: Icons.emergency_outlined,
              title: 'When to call emergency services',
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F2),
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFECACA),
                ),
              ),
              child: Text(
                item.whenToCallEmergency,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF7A271A),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Important',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'This information is for general first aid guidance and does not replace professional medical advice or emergency services.',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Color(0xFF667085),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF1976D2),
          size: 22,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF475467),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoNotItem extends StatelessWidget {
  const _DoNotItem({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.close,
            size: 20,
            color: Color(0xFFD92D20),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475467),
              ),
            ),
          ),
        ],
      ),
    );
  }
}