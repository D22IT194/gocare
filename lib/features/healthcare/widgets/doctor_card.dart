  import 'package:flutter/material.dart';

import '../models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.onCall,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFEAECF0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.03,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _DoctorAvatar(
                imageUrl:
                    doctor.profileImageUrl,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(0xFF172B4D),
                            ),
                          ),
                        ),

                        if (doctor.isVerified)
                          const Padding(
                            padding:
                                EdgeInsets.only(
                              left: 5,
                            ),
                            child: Icon(
                              Icons.verified,
                              size: 18,
                              color:
                                  Color(0xFF1976D2),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      doctor.specialityName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      doctor.qualification,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color:
                            Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color:
                              Color(0xFFF79009),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          doctor.rating
                              .toStringAsFixed(1),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Color(0xFF344054),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${doctor.reviewCount})',
                          style:
                              const TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF98A2B3),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '${doctor.experienceYears} yrs',
                          style:
                              const TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color:
                              Color(0xFF667085),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            doctor.clinicName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Color(0xFF667085),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        if (doctor.isSponsored)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFFFF4E5,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                            ),
                            child:
                                const Text(
                              'Sponsored',
                              style:
                                  TextStyle(
                                fontSize: 9,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color:
                                    Color(
                                  0xFFB54708,
                                ),
                              ),
                            ),
                          ),

                        const Spacer(),

                        Text(
                          '₹${doctor.consultationFee.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(0xFF172B4D),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton
                              .icon(
                            onPressed: onCall,
                            icon: const Icon(
                              Icons.call_outlined,
                              size: 17,
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
                                color: Color(
                                  0xFFD0D5DD,
                                ),
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 9,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              ElevatedButton(
                            onPressed: onTap,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFF1976D2,
                              ),
                              foregroundColor:
                                  Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 10,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),
                            ),
                            child: const Text(
                              'View Profile',
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

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius:
            BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.person_outline,
              size: 36,
              color: Color(0xFF1976D2),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, _, _) => const Icon(
                Icons.person_outline,
                size: 36,
                color: Color(0xFF1976D2),
              ),
            ),
    );
  }
}