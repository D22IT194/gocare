import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentService {
  AppointmentService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _appointments =>
          _firestore.collection(
            'appointments',
          );




          Future<void> cancelAppointment({
  required String appointmentId,
  required String userId,
}) async {
  final ref =
      _appointments.doc(appointmentId);

  await _firestore.runTransaction(
    (transaction) async {
      final snapshot =
          await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception(
          'Appointment not found.',
        );
      }

      final data =
          snapshot.data();

      if (data == null) {
        throw Exception(
          'Appointment information is unavailable.',
        );
      }

      if (data['userId'] != userId) {
        throw Exception(
          'You cannot cancel this appointment.',
        );
      }

      final status =
          data['status'];

      if (status == 'cancelled') {
        throw Exception(
          'Appointment is already cancelled.',
        );
      }

      if (status == 'completed') {
        throw Exception(
          'Completed appointments cannot be cancelled.',
        );
      }

      transaction.update(
        ref,
        {
          'status': 'cancelled',
          'cancelledAt':
              FieldValue.serverTimestamp(),
          'cancelledBy': userId,
        },
      );
    },
  );
}
Future<void> rescheduleAppointment({
  required String appointmentId,
  required String userId,
  required String newDate,
  required String newStartTime,
  required String newEndTime,
}) async {
  final appointmentRef =
      _appointments.doc(appointmentId);

  await _firestore.runTransaction(
    (transaction) async {
      final appointmentSnapshot =
          await transaction.get(
        appointmentRef,
      );

      if (!appointmentSnapshot.exists) {
        throw Exception(
          'Appointment not found.',
        );
      }

      final data =
          appointmentSnapshot.data();

      if (data == null) {
        throw Exception(
          'Appointment data is unavailable.',
        );
      }

      if (data['userId'] != userId) {
        throw Exception(
          'You cannot modify this appointment.',
        );
      }

      final status =
          data['status'];

      if (status == 'cancelled' ||
          status == 'completed' ||
          status == 'rejected') {
        throw Exception(
          'This appointment cannot be rescheduled.',
        );
      }

      final doctorId =
          data['doctorId'];

      final oldDate =
          data['date'];

      final oldStartTime =
          data['startTime'];

      final newSlotId =
          '${doctorId}_${newDate}_$newStartTime';

      final oldSlotId =
          '${doctorId}_${oldDate}_$oldStartTime';

      final newSlotRef =
          _firestore
              .collection('doctor_slots')
              .doc(newSlotId);

      final oldSlotRef =
          _firestore
              .collection('doctor_slots')
              .doc(oldSlotId);

      final newSlotSnapshot =
          await transaction.get(
        newSlotRef,
      );

      if (!newSlotSnapshot.exists) {
        throw Exception(
          'Selected slot is no longer available.',
        );
      }

      final newSlotData =
          newSlotSnapshot.data();

      if (newSlotData == null ||
          newSlotData['isBooked'] == true) {
        throw Exception(
          'Selected slot is already booked.',
        );
      }

      transaction.update(
        newSlotRef,
        {
          'isBooked': true,
          'bookedBy': userId,
          'appointmentId':
              appointmentId,
        },
      );

      transaction.update(
        oldSlotRef,
        {
          'isBooked': false,
          'bookedBy': null,
          'appointmentId': null,
        },
      );

      transaction.update(
        appointmentRef,
        {
          'date': newDate,
          'startTime':
              newStartTime,
          'endTime':
              newEndTime,
          'status': 'pending',
          'rescheduledAt':
              FieldValue.serverTimestamp(),
        },
      );
    },
  );
}

  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String userId,
    required String patientName,
    required String date,
    required String startTime,
    required String endTime,
    required double consultationFee,
  }) async {
    final slotId =
        '${doctorId}_${date}_$startTime';

    final appointmentRef =
        _appointments.doc(slotId);

    await _firestore.runTransaction(
      (transaction) async {
        final snapshot =
            await transaction.get(
          appointmentRef,
        );

        if (snapshot.exists) {
          final data = snapshot.data();

          final status =
              data?['status'];

          if (status == 'pending' ||
              status == 'confirmed') {
            throw Exception(
              'This appointment slot is already booked.',
            );
          }
        }

        transaction.set(
          appointmentRef,
          {
            'doctorId': doctorId,
            'doctorName': doctorName,
            'userId': userId,
            'patientName': patientName,
            'date': date,
            'startTime': startTime,
            'endTime': endTime,
            'status': 'pending',
            'consultationFee':
                consultationFee,
            'createdAt':
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  Stream<Set<String>> watchBookedSlots({
    required String doctorId,
    required String date,
  }) {
    return _appointments
        .where(
          'doctorId',
          isEqualTo: doctorId,
        )
        .where(
          'date',
          isEqualTo: date,
        )
        .where(
          'status',
          whereIn: [
            'pending',
            'confirmed',
          ],
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) =>
                      doc.data()['startTime']
                          as String? ??
                      '',
                )
                .where(
                  (time) => time.isNotEmpty,
                )
                .toSet();
          },
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchUserAppointments(
    String userId,
  ) {
    return _appointments
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }
}