import 'package:flutter/material.dart';

import '../models/speciality_model.dart';

class SpecialityCard extends StatelessWidget {
  const SpecialityCard({
    super.key,
    required this.speciality,
    required this.selected,
    required this.onTap,
  });

  final SpecialityModel speciality;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF1976D2)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1976D2)
                  : const Color(0xFFEAECF0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 18,
                color: selected
                    ? Colors.white
                    : const Color(0xFF1976D2),
              ),
              const SizedBox(width: 7),
              Text(
                speciality.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF344054),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}