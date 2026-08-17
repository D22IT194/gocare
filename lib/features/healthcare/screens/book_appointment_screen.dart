import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/appointment_slot_model.dart';
import '../models/doctor_availability_model.dart';
import '../models/doctor_model.dart';
import '../services/appointment_service.dart';
import '../services/appointment_slot_service.dart';
import '../services/doctor_service.dart';

class BookAppointmentScreen
    extends StatefulWidget {
  const BookAppointmentScreen({
    super.key,
    required this.doctor,
  });

  final DoctorModel doctor;

  @override
  State<BookAppointmentScreen>
      createState() =>
          _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  final DoctorService _doctorService =
      DoctorService();

  final AppointmentService
      _appointmentService =
      AppointmentService();

  DateTime _selectedDate =
      DateTime.now();

  String? _selectedSlot;

  bool _booking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Book Appointment',
        ),
        centerTitle: true,
      ),

      bottomNavigationBar:
          _buildBottomBar(),

      body: StreamBuilder<
          List<DoctorAvailabilityModel>>(
        stream:
            _doctorService
                .watchAvailability(
          doctorId:
              widget.doctor.id,
        ),
        builder:
            (context, availabilitySnapshot) {
          if (availabilitySnapshot
                  .connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (availabilitySnapshot
              .hasError) {
            return _ErrorState(
              message:
                  'Unable to load doctor availability.',
            );
          }

          final availability =
              availabilitySnapshot
                      .data ??
                  [];

          final todayAvailability =
              availability
                  .where(
                    (item) =>
                        item.dayOfWeek ==
                        _selectedDate
                            .weekday,
                  )
                  .toList();

          return StreamBuilder<
              Set<String>>(
            stream:
                _appointmentService
                    .watchBookedSlots(
              doctorId:
                  widget.doctor.id,
              date:
                  _dateKey(_selectedDate),
            ),
            builder:
                (
              context,
              bookedSnapshot,
            ) {
              if (bookedSnapshot
                      .connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final bookedSlots =
                  bookedSnapshot
                          .data ??
                      <String>{};

              return ListView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                children: [
                  _DoctorSummary(
                    doctor:
                        widget.doctor,
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  const Text(
                    'Select Date',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _DateSelector(
                    selectedDate:
                        _selectedDate,
                    onChanged:
                        (date) {
                      setState(() {
                        _selectedDate =
                            date;
                        _selectedSlot =
                            null;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'Available Time',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    _formatDate(
                      _selectedDate,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF667085),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (todayAvailability
                      .isEmpty)
                    const _NoAvailability()
                  else
                    ...todayAvailability
                        .map(
                      (
                        schedule,
                      ) {
                        final slots =
                            AppointmentSlotService
                                .generateSlots(
                          availability:
                              schedule,
                          bookedSlots:
                              bookedSlots,
                        );

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 18,
                          ),
                          child:
                              _ScheduleSection(
                            availability:
                                schedule,
                            slots:
                                slots,
                            selectedSlot:
                                _selectedSlot,
                            onSelect:
                                (slot) {
                              if (slot
                                  .isBooked) {
                                return;
                              }

                              setState(() {
                                _selectedSlot =
                                    slot
                                        .startTime;
                              });
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(
                    height: 15,
                  ),

                  _BookingInformation(
                    doctor:
                        widget.doctor,
                  ),

                  const SizedBox(
                    height: 120,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          10,
        ),
        decoration:
            const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color:
                  Color(0xFFEAECF0),
            ),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _selectedSlot == null ||
                        _booking
                    ? null
                    : _bookAppointment,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF1976D2,
              ),
              foregroundColor:
                  Colors.white,
              disabledBackgroundColor:
                  const Color(
                0xFFD0D5DD,
              ),
              elevation: 0,
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 14,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
            child: _booking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          Colors.white,
                    ),
                  )
                : Text(
                    _selectedSlot == null
                        ? 'Select a Time'
                        : 'Confirm ${_selectedSlot!}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    final slot =
        _selectedSlot;

    if (slot == null) {
      return;
    }

    final user =
        FirebaseAuth.instance
            .currentUser;

    if (user == null) {
      _showMessage(
        'Please login before booking an appointment.',
      );
      return;
    }

    setState(() {
      _booking = true;
    });

    try {
      final endTime =
          _calculateEndTime(
        slot,
        30,
      );

      await _appointmentService
          .bookAppointment(
        doctorId:
            widget.doctor.id,
        doctorName:
            widget.doctor.name,
        userId:
            user.uid,
        patientName:
            user.displayName ??
                'Patient',
        date:
            _dateKey(
          _selectedDate,
        ),
        startTime:
            slot,
        endTime:
            endTime,
        consultationFee:
            widget.doctor
                .consultationFee,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
          title: const Text(
            'Appointment Requested',
          ),
          content: Text(
            'Your appointment request with '
            '${widget.doctor.name} has been submitted.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Done'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _booking = false;
        });
      }
    }
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _calculateEndTime(
    String start,
    int duration,
  ) {
    final parts =
        start.split(':');

    final hour =
        int.parse(parts[0]);

    final minute =
        int.parse(parts[1]);

    final total =
        hour * 60 +
            minute +
            duration;

    return '${(total ~/ 60).toString().padLeft(2, '0')}:'
        '${(total % 60).toString().padLeft(2, '0')}';
  }

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}
class _DateSelector
    extends StatelessWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.onChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today =
        DateTime.now();

    final dates = List.generate(
      14,
      (index) =>
          DateTime(
        today.year,
        today.month,
        today.day + index,
      ),
    );

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder:
            (_, _) =>
                const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final date =
              dates[index];

          final selected =
              date.year ==
                      selectedDate.year &&
                  date.month ==
                      selectedDate.month &&
                  date.day ==
                      selectedDate.day;

          return InkWell(
            onTap: () =>
                onChanged(date),
            borderRadius:
                BorderRadius.circular(
              14,
            ),
            child: Container(
              width: 68,
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 9,
              ),
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF1976D2)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border:
                    Border.all(
                  color: selected
                      ? const Color(
                          0xFF1976D2)
                      : const Color(
                          0xFFEAECF0),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Text(
                    _weekday(
                      date,
                    ),
                    style:
                        TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF667085),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${date.day}',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : const Color(
                              0xFF172B4D),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekday(
    DateTime date,
  ) {
    const names = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return names[
        date.weekday - 1];
  }
}
class _ScheduleSection
    extends StatelessWidget {
  const _ScheduleSection({
    required this.availability,
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  final DoctorAvailabilityModel
      availability;

  final List<AppointmentSlotModel>
      slots;

  final String? selectedSlot;

  final ValueChanged<
      AppointmentSlotModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          '${availability.startTime} - ${availability.endTime}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w700,
            color:
                Color(0xFF667085),
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map(
            (slot) {
              final selected =
                  slot.startTime ==
                      selectedSlot;

              return InkWell(
                onTap: () =>
                    onSelect(slot),
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
                child: Container(
                  width: 86,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 11,
                  ),
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color: slot.isBooked
                        ? const Color(
                            0xFFF2F4F7)
                        : selected
                            ? const Color(
                                0xFF1976D2)
                            : Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                    border:
                        Border.all(
                      color: slot.isBooked
                          ? const Color(
                              0xFFEAECF0)
                          : selected
                              ? const Color(
                                  0xFF1976D2)
                              : const Color(
                                  0xFFEAECF0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        slot.startTime,
                        style:
                            TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w800,
                          color: slot.isBooked
                              ? const Color(
                                  0xFF98A2B3)
                              : selected
                                  ? Colors
                                      .white
                                  : const Color(
                                      0xFF344054),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        slot.isBooked
                            ? 'Booked'
                            : 'Available',
                        style:
                            TextStyle(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w600,
                          color: slot.isBooked
                              ? const Color(
                                  0xFF98A2B3)
                              : selected
                                  ? Colors
                                      .white
                                  : const Color(
                                      0xFF12B76A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}
class _NoAvailability
    extends StatelessWidget {
  const _NoAvailability();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(25),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFEAECF0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons
                .event_busy_outlined,
            size: 42,
            color:
                Color(0xFF98A2B3),
          ),
          SizedBox(height: 10),
          Text(
            'No appointments available',
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172B4D),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'This doctor is not available on the selected date.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color:
                  Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,
              size: 45,
              color:
                  Color(0xFF98A2B3),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorSummary extends StatelessWidget {
  const _DoctorSummary({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: doctor.profileImageUrl.isNotEmpty
                ? NetworkImage(doctor.profileImageUrl)
                : null,
            child: doctor.profileImageUrl.isEmpty
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialityName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.clinicName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
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

class _BookingInformation extends StatelessWidget {
  const _BookingInformation({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAECF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consultation Fee',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF667085),
                ),
              ),
              Text(
                '₹${doctor.consultationFee.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}