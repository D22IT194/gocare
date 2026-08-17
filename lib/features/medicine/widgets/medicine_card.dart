import 'package:flutter/material.dart';

import '../models/medicine_model.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    this.onSave,
    this.isSaved = false,
  });

  final MedicineModel medicine;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _MedicineImage(
                  imageUrl: medicine.imageUrl,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Color(0xFF172B4D),
                              ),
                            ),
                          ),

                          if (onSave != null)
                            InkWell(
                              onTap: onSave,
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  4,
                                ),
                                child: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons
                                          .bookmark_border,
                                  size: 22,
                                  color: isSaved
                                      ? const Color(
                                          0xFF1976D2,
                                        )
                                      : const Color(
                                          0xFF667085,
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      if (medicine
                          .genericName
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          medicine.genericName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Tag(
                            icon:
                                Icons.category_outlined,
                            text: medicine.category,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        medicine.description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF667085),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF1976D2),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'View medicine information',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Color(0xFF1976D2),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color:
                                Color(0xFF98A2B3),
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
      ),
    );
  }
}

class _MedicineImage extends StatelessWidget {
  const _MedicineImage({
    this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) {
                return const _MedicinePlaceholder();
              },
              loadingBuilder:
                  (context, child, progress) {
                if (progress == null) {
                  return child;
                }

                return const _MedicinePlaceholder();
              },
            )
          : const _MedicinePlaceholder(),
    );
  }
}

class _MedicinePlaceholder
    extends StatelessWidget {
  const _MedicinePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.medication_outlined,
        size: 34,
        color: Color(0xFF1976D2),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF667085),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}