import 'package:cloud_firestore/cloud_firestore.dart';


enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  rejected,
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.consultationFee,
    required this.createdAt,
  });

  final String id;

  final String doctorId;
  final String userId;

  final String doctorName;
  final String patientName;

  /// yyyy-MM-dd
  final String date;

  final String startTime;
  final String endTime;

  final AppointmentStatus status;

  final double consultationFee;

  final DateTime createdAt;

  factory AppointmentModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AppointmentModel(
      id: id,
      doctorId:
          map['doctorId'] as String? ?? '',
      userId:
          map['userId'] as String? ?? '',
      doctorName:
          map['doctorName'] as String? ?? '',
      patientName:
          map['patientName'] as String? ?? '',
      date:
          map['date'] as String? ?? '',
      startTime:
          map['startTime'] as String? ?? '',
      endTime:
          map['endTime'] as String? ?? '',
      status: AppointmentStatus.values
          .firstWhere(
        (value) =>
            value.name ==
            map['status'],
        orElse: () =>
            AppointmentStatus.pending,
      ),
      consultationFee:
          (map['consultationFee'] as num?)
                  ?.toDouble() ??
              0,
      createdAt:
          (map['createdAt']
                  as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'doctorName': doctorName,
      'patientName': patientName,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name,
      'consultationFee': consultationFee,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ),
    };
  }
}