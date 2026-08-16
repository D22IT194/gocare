import 'package:flutter/material.dart';

import '../models/healthcare_facility_model.dart';

class HealthcareFacilityCard
    extends StatelessWidget {
const HealthcareFacilityCard({
  super.key,
  required this.facility,
  required this.onTap,
  this.onCall,
  this.onDirections,
  this.distance,
});

  final HealthcareFacilityModel
      facility;

  final VoidCallback onTap;

  final VoidCallback? onCall;

  final VoidCallback? onDirections;

  final String? distance;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(
                0xFFEAECF0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  _FacilityImage(
                    facility: facility,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                facility
                                    .name,
                                maxLines:
                                    2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color:
                                      Color(
                                    0xFF172B4D,
                                  ),
                                ),
                              ),
                            ),

                            const Icon(
                              Icons
                                  .chevron_right_rounded,
                              color:
                                  Color(
                                0xFF98A2B3,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          facility
                              .typeLabel,
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight
                                    .w600,
                            color:
                                Color(
                              0xFF1976D2,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .star_rounded,
                              size: 17,
                              color:
                                  Color(
                                0xFFF79009,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              facility.rating
                                  .toStringAsFixed(
                                1,
                              ),
                              style:
                                  const TextStyle(
                                fontSize:
                                    12,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              '(${facility.reviewCount})',
                              style:
                                  const TextStyle(
                                fontSize:
                                    11,
                                color:
                                    Color(
                                  0xFF98A2B3,
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

              const SizedBox(
                height: 12,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Icon(
                    Icons
                        .location_on_outlined,
                    size: 17,
                    color:
                        Color(0xFF667085),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Expanded(
                    child: Text(
                      facility.address,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Color(
                          0xFF667085,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (facility
                      .isVerified)
                    _Badge(
                      icon: Icons
                          .verified_outlined,
                      text: 'Verified',
                    ),

                  if (facility
                      .isEmergencyAvailable)
                    _Badge(
                      icon: Icons
                          .emergency_outlined,
                      text: 'Emergency',
                      danger: true,
                    ),

                  if (facility
                      .isOpen24Hours)
                    const _Badge(
                      icon: Icons
                          .schedule_outlined,
                      text: '24/7',
                    ),

                  if (facility
                      .isSponsored)
                    const _Badge(
                      icon: Icons
                          .workspace_premium_outlined,
                      text: 'Sponsored',
                    ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  if (onCall != null)
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            onCall,
                        icon:
                            const Icon(
                          Icons
                              .phone_outlined,
                          size: 16,
                        ),
                        label:
                            const Text(
                          'Call',
                        ),
                      ),
                    ),

                  if (onCall != null &&
                      onDirections != null)
                    const SizedBox(
                      width: 8,
                    ),

                  if (onDirections !=
                      null)
                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            onDirections,
                        icon:
                            const Icon(
                          Icons
                              .directions_outlined,
                          size: 16,
                        ),
                        label:
                            const Text(
                          'Directions',
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacilityImage
    extends StatelessWidget {
  const _FacilityImage({
    required this.facility,
  });

  final HealthcareFacilityModel
      facility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color:
            const Color(0xFFEAF4FF),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: facility.imageUrl
              .isEmpty
          ? const Icon(
              Icons
                  .local_hospital_outlined,
              size: 32,
              color:
                  Color(0xFF1976D2),
            )
          : ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              child:
                  Image.network(
                facility.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, _, _) =>
                        const Icon(
                  Icons
                      .local_hospital_outlined,
                  size: 32,
                  color:
                      Color(0xFF1976D2),
                ),
              ),
            ),
    );
  }
}

class _Badge
    extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.text,
    this.danger = false,
  });

  final IconData icon;
  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: danger
            ? const Color(0xFFFFF1F0)
            : const Color(0xFFF2F4F7),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: danger
                ? const Color(
                    0xFFD92D20,
                  )
                : const Color(
                    0xFF667085,
                  ),
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w700,
              color: danger
                  ? const Color(
                      0xFFD92D20,
                    )
                  : const Color(
                      0xFF475467,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}