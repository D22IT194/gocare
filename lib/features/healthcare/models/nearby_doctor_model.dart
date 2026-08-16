import 'doctor_model.dart';

class NearbyDoctorModel {
  const NearbyDoctorModel({
    required this.doctor,
    required this.distanceKm,
  });

  final DoctorModel doctor;
  final double distanceKm;

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }
}