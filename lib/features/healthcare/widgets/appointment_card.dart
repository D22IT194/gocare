import 'package:flutter/material.dart';
import '../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    this.appointment,
    this.doctorName,
    this.speciality,
    this.date,
    this.time,
    this.status,
    this.doctorImageUrl,
    this.facilityName,
    this.onTap,
    this.onCancel,
    this.onReschedule,
  });

  final AppointmentModel? appointment;

  final String? doctorName;

  final String? speciality;

  final String? date;

  final String? time;

  final String? status;

  final String? doctorImageUrl;

  final String? facilityName;

  final VoidCallback? onTap;

  final VoidCallback? onCancel;

  final VoidCallback? onReschedule;

  String get effectiveDoctorName => appointment?.doctorName ?? doctorName ?? '';

  String get effectiveSpeciality => speciality ?? 'Healthcare Professional';

  String get effectiveDate => appointment?.date ?? date ?? '';

  String get effectiveTime => appointment != null
      ? '${appointment!.startTime} - ${appointment!.endTime}'
      : (time ?? '');

  String get effectiveStatus => appointment?.status.name ?? status ?? 'pending';

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(16),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFFEAECF0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // TOP
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _DoctorAvatar(
                    imageUrl:
                        doctorImageUrl,
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
                        Text(
                          effectiveDoctorName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w800,
                            color:
                                Color(
                              0xFF172B4D,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          effectiveSpeciality,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            // fontWeight: 600,
                            color:
                                Color(
                              0xFF1976D2,
                            ),
                          ),
                        ),

                        if (facilityName !=
                            null &&
                            facilityName!
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            facilityName!,
                            maxLines: 1,
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
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  _StatusBadge(
                    status: effectiveStatus,
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // DATE / TIME
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFF8FAFC,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          _AppointmentInfo(
                        icon: Icons
                            .calendar_today_outlined,
                        title: 'Date',
                        value: effectiveDate,
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 34,
                      color:
                          const Color(
                        0xFFEAECF0,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child:
                          _AppointmentInfo(
                        icon: Icons
                            .access_time_outlined,
                        title: 'Time',
                        value: effectiveTime,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ACTIONS
              // ==================================================

              if (onCancel != null ||
                  onReschedule != null) ...[
                const SizedBox(
                  height: 14,
                ),

                Row(
                  children: [
                    if (onReschedule !=
                        null)
                      Expanded(
                        child:
                            OutlinedButton(
                          onPressed:
                              onReschedule,
                          child:
                              const Text(
                            'Reschedule',
                          ),
                        ),
                      ),

                    if (onReschedule !=
                            null &&
                        onCancel != null)
                      const SizedBox(
                        width: 10,
                      ),

                    if (onCancel != null)
                      Expanded(
                        child:
                            OutlinedButton(
                          onPressed:
                              onCancel,
                          style:
                              OutlinedButton
                                  .styleFrom(
                            foregroundColor:
                                const Color(
                              0xFFD92D20,
                            ),
                            side:
                                const BorderSide(
                              color:
                                  Color(
                                0xFFFECACA,
                              ),
                            ),
                          ),
                          child:
                              const Text(
                            'Cancel',
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// DOCTOR AVATAR
// ================================================================

class _DoctorAvatar
    extends StatelessWidget {
  const _DoctorAvatar({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(
    BuildContext context,
  ) {
    final hasImage =
        imageUrl != null &&
        imageUrl!
            .trim()
            .isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFEAF4FF,
        ),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons
                      .person_outline_rounded,
                  size: 30,
                  color:
                      Color(
                    0xFF1976D2,
                  ),
                );
              },
            )
          : const Icon(
              Icons
                  .person_outline_rounded,
              size: 30,
              color:
                  Color(
                0xFF1976D2,
              ),
            ),
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge
    extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(
    BuildContext context,
  ) {
    final normalized =
        status
            .trim()
            .toLowerCase();

    final bool isCancelled =
        normalized ==
                'cancelled' ||
            normalized ==
                'canceled';

    final bool isCompleted =
        normalized ==
            'completed';

    final bool isPending =
        normalized ==
            'pending';

    Color background;
    Color foreground;

    if (isCancelled) {
      background =
          const Color(
        0xFFFFF1F0,
      );
      foreground =
          const Color(
        0xFFD92D20,
      );
    } else if (isCompleted) {
      background =
          const Color(
        0xFFECFDF3,
      );
      foreground =
          const Color(
        0xFF027A48,
      );
    } else if (isPending) {
      background =
          const Color(
        0xFFFFFAEB,
      );
      foreground =
          const Color(
        0xFFB54708,
      );
    } else {
      background =
          const Color(
        0xFFEAF4FF,
      );
      foreground =
          const Color(
        0xFF1976D2,
      );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        status,
        style:
            TextStyle(
          fontSize: 11,
          fontWeight:
              FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

// ================================================================
// APPOINTMENT INFO
// ================================================================

class _AppointmentInfo
    extends StatelessWidget {
  const _AppointmentInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;

  final String title;

  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFEAF4FF,
            ),
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color:
                const Color(
              0xFF1976D2,
            ),
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 11,
                  color:
                      Color(
                    0xFF98A2B3,
                  ),
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(
                    0xFF344054,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}