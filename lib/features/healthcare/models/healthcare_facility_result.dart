import 'healthcare_facility_model.dart';

class HealthcareFacilityResult {
  const HealthcareFacilityResult({
    required this.facility,
    required this.distanceKm,
  });

  final HealthcareFacilityModel facility;

  final double distanceKm;

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }

    return '${distanceKm.toStringAsFixed(1)} km';
  }
}