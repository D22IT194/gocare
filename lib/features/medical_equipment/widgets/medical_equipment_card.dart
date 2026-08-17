import 'package:flutter/material.dart';

import '../models/medical_equipment_model.dart';

class MedicalEquipmentCard extends StatelessWidget {
  const MedicalEquipmentCard({
    super.key,
    required this.equipment,
    required this.onTap,
  });

  final MedicalEquipmentModel equipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EquipmentImage(
                imageUrl: equipment.imageUrl,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            equipment.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF98A2B3),
                        ),
                      ],
                    ),

                    if (equipment.brand != null &&
                        equipment.brand!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),

                      Text(
                        equipment.brand!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],

                    const SizedBox(height: 9),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF4FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        equipment.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      equipment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 9),

                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF1976D2),
                        ),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'View equipment information',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EQUIPMENT IMAGE
// ============================================================

class _EquipmentImage extends StatelessWidget {
  const _EquipmentImage({
    this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const _EquipmentPlaceholder();
              },
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const _EquipmentPlaceholder();
              },
            )
          : const _EquipmentPlaceholder(),
    );
  }
}

// ============================================================
// IMAGE PLACEHOLDER
// ============================================================

class _EquipmentPlaceholder extends StatelessWidget {
  const _EquipmentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.medical_services_outlined,
        size: 36,
        color: Color(0xFF1976D2),
      ),
    );
  }
}