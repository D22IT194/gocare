import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../widgets/appointment_status_chip.dart';

class AppointmentDetailScreen
    extends StatefulWidget {
  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  final AppointmentModel appointment;

  @override
  State<AppointmentDetailScreen>
      createState() =>
          _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends State<
        AppointmentDetailScreen> {
  final AppointmentService
      _service =
      AppointmentService();

  bool _cancelling = false;

  Future<void> _cancelAppointment()
      async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel appointment?',
          ),
          content: const Text(
            'Are you sure you want to cancel this appointment?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Keep'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFD92D20,
                ),
              ),
              child:
                  const Text(
                'Cancel Appointment',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final user =
        FirebaseAuth.instance
            .currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      _cancelling = true;
    });

    try {
      await _service
          .cancelAppointment(
        appointmentId:
            widget.appointment.id,
        userId: user.uid,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Appointment cancelled.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment =
        widget.appointment;

    final canCancel =
        appointment.status ==
                AppointmentStatus
                    .pending ||
            appointment.status ==
                AppointmentStatus
                    .confirmed;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Appointment Details',
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          Container(
            padding:
                const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              border: Border.all(
                color:
                    const Color(
                  0xFFEAECF0,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFEAF4FF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .medical_services_outlined,
                    size: 36,
                    color:
                        Color(0xFF1976D2),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  appointment
                      .doctorName,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xFF172B4D),
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                AppointmentStatusChip(
                  status:
                      appointment.status,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _InfoCard(
            title: 'Appointment',
            children: [
              _InfoRow(
                icon: Icons
                    .calendar_today_outlined,
                title: 'Date',
                value:
                    appointment.date,
              ),
              _InfoRow(
                icon: Icons
                    .access_time_outlined,
                title: 'Time',
                value:
                    '${appointment.startTime} - ${appointment.endTime}',
              ),
              _InfoRow(
                icon: Icons
                    .person_outline,
                title: 'Patient',
                value:
                    appointment.patientName,
              ),
              _InfoRow(
                icon: Icons
                    .payments_outlined,
                title: 'Fee',
                value:
                    '₹${appointment.consultationFee.toStringAsFixed(0)}',
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          if (canCancel)
            SizedBox(
              width: double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    _cancelling
                        ? null
                        : _cancelAppointment,
                icon: _cancelling
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons
                            .cancel_outlined,
                      ),
                label: Text(
                  _cancelling
                      ? 'Cancelling...'
                      : 'Cancel Appointment',
                ),
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(
                    0xFFD92D20,
                  ),
                  side:
                      const BorderSide(
                    color:
                        Color(0xFFFECACA),
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCard
    extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
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
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF172B4D),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color:
                const Color(0xFF667085),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF98A2B3),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.end,
              style:
                  const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }
}