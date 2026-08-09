import 'package:flutter/material.dart';

import '../models/health_information.dart';

class HealthInfoSection extends StatelessWidget {
  const HealthInfoSection({
    super.key,
    required this.healthInformation,
    required this.onTap,
  });

  final HealthInformation? healthInformation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final health = healthInformation;

    final hasInformation =
        health != null &&
        (health.bloodGroup != null ||
            health.gender != null ||
            health.height != null ||
            health.weight != null ||
            health.allergies != null ||
            health.medicalConditions != null ||
            health.currentMedications != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF172B4D),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your personal medical information',
                      style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: const Color(0xFF1976D2),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (!hasInformation)
            _EmptyHealthInformation(onTap: onTap)
          else
            _HealthSummary(healthInformation: health, onTap: onTap),
        ],
      ),
    );
  }
}

class _EmptyHealthInformation extends StatelessWidget {
  const _EmptyHealthInformation({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.medical_information_outlined,
            size: 32,
            color: Color(0xFF98A2B3),
          ),

          const SizedBox(height: 10),

          const Text(
            'Health information not added yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF344054),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Add your health information to help '
            'during emergencies.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF667085),
            ),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: onTap,
            child: const Text('Add Health Information'),
          ),
        ],
      ),
    );
  }
}

class _HealthSummary extends StatelessWidget {
  const _HealthSummary({required this.healthInformation, required this.onTap});

  final HealthInformation healthInformation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (healthInformation.bloodGroup != null)
          _InfoRow(
            icon: Icons.bloodtype_outlined,
            label: 'Blood Group',
            value: healthInformation.bloodGroup!,
          ),

        if (healthInformation.gender != null)
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Gender',
            value: healthInformation.gender!,
          ),

        if (healthInformation.height != null)
          _InfoRow(
            icon: Icons.height,
            label: 'Height',
            value: '${healthInformation.height!.toStringAsFixed(0)} cm',
          ),

        if (healthInformation.weight != null)
          _InfoRow(
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            value: '${healthInformation.weight!.toStringAsFixed(1)} kg',
          ),

        if (healthInformation.allergies != null)
          _InfoRow(
            icon: Icons.warning_amber_outlined,
            label: 'Allergies',
            value: healthInformation.allergies!,
          ),

        if (healthInformation.medicalConditions != null)
          _InfoRow(
            icon: Icons.medical_information_outlined,
            label: 'Medical Conditions',
            value: healthInformation.medicalConditions!,
          ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onTap,
            child: const Text('View & Edit Health Information'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF667085)),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF98A2B3),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
