import 'package:flutter/material.dart';

import '../models/nearby_doctor_model.dart';

class NearbyDoctorCard
    extends StatelessWidget {
  const NearbyDoctorCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onCall,
  });

  final NearbyDoctorModel item;

  final VoidCallback onTap;

  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final doctor =
        item.doctor;

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
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border:
                Border.all(
              color:
                  const Color(
                0xFFEAECF0,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFEAF4FF,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        17,
                      ),
                    ),
                    child:
                        doctor
                                .profileImageUrl
                                .isEmpty
                            ? const Icon(
                                Icons
                                    .person_outline,
                                size: 34,
                                color:
                                    Color(
                                  0xFF1976D2,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  17,
                                ),
                                child:
                                    Image
                                        .network(
                                  doctor
                                      .profileImageUrl,
                                  fit: BoxFit
                                      .cover,
                                ),
                              ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child:
                                  Text(
                                doctor.name,
                                maxLines:
                                    1,
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

                            if (doctor
                                .isVerified)
                              const Padding(
                                padding:
                                    EdgeInsets
                                        .only(
                                  left: 5,
                                ),
                                child:
                                    Icon(
                                  Icons
                                      .verified,
                                  size:
                                      17,
                                  color:
                                      Color(
                                    0xFF1976D2,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          doctor
                              .specialityName,
                          style:
                              const TextStyle(
                            fontSize:
                                12,
                            color:
                                Color(
                              0xFF667085,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .star_rounded,
                              size:
                                  17,
                              color:
                                  Color(
                                0xFFF79009,
                              ),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              doctor.rating
                                  .toStringAsFixed(
                                1,
                              ),
                              style:
                                  const TextStyle(
                                fontSize:
                                    11,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                            Text(
                              ' (${doctor.reviewCount})',
                              style:
                                  const TextStyle(
                                fontSize:
                                    10,
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

                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    color:
                        Color(0xFF98A2B3),
                  ),
                ],
              ),

              const SizedBox(
                height: 13,
              ),

              Row(
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
                      item
                          .formattedDistance,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFF475467,
                        ),
                      ),
                    ),
                  ),

                  if (onCall != null)
                    SizedBox(
                      height: 34,
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            onCall,
                        icon:
                            const Icon(
                          Icons
                              .phone_outlined,
                          size: 15,
                        ),
                        label:
                            const Text(
                          'Call',
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              const Color(
                            0xFF1976D2,
                          ),
                          side:
                              const BorderSide(
                            color:
                                Color(
                              0xFFB2DDFF,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                11,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              9,
                            ),
                          ),
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