import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../widgets/appointment_card.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen
    extends StatelessWidget {
  const AppointmentsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance
            .currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login to view appointments.',
          ),
        ),
      );
    }

    final service =
        AppointmentService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF8FAFC),

        appBar: AppBar(
          title: const Text(
            'My Appointments',
          ),
          centerTitle: true,
          bottom:
              const TabBar(
            tabs: [
              Tab(
                text: 'Upcoming',
              ),
              Tab(
                text: 'History',
              ),
            ],
          ),
        ),

        body: StreamBuilder<
            dynamic>(
          stream:
              service
                  .watchUserAppointments(
            user.uid,
          ),
          builder:
              (context, snapshot) {
            if (snapshot
                    .connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const _ErrorState();
            }

            final docs =
                snapshot.data?.docs ??
                    [];

            final appointments =
                docs.map<
                    AppointmentModel>(
              (doc) {
                return AppointmentModel
                    .fromMap(
                  doc.id,
                  doc.data(),
                );
              },
            ).toList();

            final upcoming =
                appointments
                    .where(
                      (item) =>
                          item.status ==
                              AppointmentStatus
                                  .pending ||
                          item.status ==
                              AppointmentStatus
                                  .confirmed,
                    )
                    .toList();

            final history =
                appointments
                    .where(
                      (item) =>
                          item.status ==
                              AppointmentStatus
                                  .completed ||
                          item.status ==
                              AppointmentStatus
                                  .cancelled ||
                          item.status ==
                              AppointmentStatus
                                  .rejected,
                    )
                    .toList();

            return TabBarView(
              children: [
                _AppointmentList(
                  appointments:
                      upcoming,
                ),
                _AppointmentList(
                  appointments:
                      history,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentList
    extends StatelessWidget {
  const _AppointmentList({
    required this.appointments,
  });

  final List<AppointmentModel>
      appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const _EmptyAppointments();
    }

    return ListView.separated(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),
      itemCount:
          appointments.length,
      separatorBuilder:
          (_, _) =>
              const SizedBox(
        height: 12,
      ),
      itemBuilder:
          (context, index) {
        final appointment =
            appointments[index];

        return AppointmentCard(
          appointment:
              appointment,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AppointmentDetailScreen(
                  appointment:
                      appointment,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyAppointments
    extends StatelessWidget {
  const _EmptyAppointments();

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
            Container(
              width: 74,
              height: 74,
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
                  22,
                ),
              ),
              child: const Icon(
                Icons
                    .event_available_outlined,
                size: 38,
                color:
                    Color(0xFF1976D2),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            const Text(
              'No appointments',
              style: TextStyle(
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
            const Text(
              'Your appointments will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
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

class _ErrorState
    extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(30),
        child: Text(
          'Unable to load appointments.',
          style: TextStyle(
            color:
                Color(0xFF667085),
          ),
        ),
      ),
    );
  }
}