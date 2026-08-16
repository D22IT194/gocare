import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor_availability_model.dart';
import '../models/doctor_model.dart';
import '../models/nearby_doctor_model.dart';
import 'doctor_distance_service.dart';

class DoctorService {
  DoctorService({
    FirebaseFirestore? firestore,
  }) : _firestore =
            firestore ??
                FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _doctors =>
          _firestore.collection(
            'doctors',
          );

  Future<List<DoctorModel>> getDoctors() async {
    final snapshot = await _doctors
        .where(
          'isActive',
          isEqualTo: true,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => DoctorModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  Stream<List<DoctorAvailabilityModel>> watchAvailability({
    required String doctorId,
  }) {
    return _doctors
        .doc(doctorId)
        .collection('availability')
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => DoctorAvailabilityModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<DoctorModel>>
      watchDoctors() {
    return _doctors
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) =>
                      DoctorModel.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList();
          },
        );
  }

  Future<List<NearbyDoctorModel>>
      getNearbyDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
  }) async {
    final snapshot =
        await _doctors
            .where(
              'isActive',
              isEqualTo: true,
            )
            .get();

    final nearbyDoctors =
        <NearbyDoctorModel>[];

    for (final doc
        in snapshot.docs) {
      final doctor =
          DoctorModel.fromMap(
        doc.id,
        doc.data(),
      );

      final distance =
          DoctorDistanceService
              .calculateKm(
        latitude1: latitude,
        longitude1: longitude,
        latitude2:
            doctor.latitude,
        longitude2:
            doctor.longitude,
      );

      if (distance <= radiusKm) {
        nearbyDoctors.add(
          NearbyDoctorModel(
            doctor: doctor,
            distanceKm:
                distance,
          ),
        );
      }
    }

    nearbyDoctors.sort(
      (a, b) =>
          a.distanceKm
              .compareTo(
        b.distanceKm,
      ),
    );

    return nearbyDoctors;
  }

  Future<List<DoctorModel>>
    getDoctorsByFacility(
  String facilityId,
) async {
  final snapshot =
      await _firestore
          .collection('doctors')
          .where(
            'facilityIds',
            arrayContains: facilityId,
          )
          .where(
            'isActive',
            isEqualTo: true,
          )
          .get();

  return snapshot.docs
      .map(
        (doc) => DoctorModel.fromMap(
          doc.id,
          doc.data(),
        ),
      )
      .toList();
}
}