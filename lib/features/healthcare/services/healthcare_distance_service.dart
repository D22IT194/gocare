import 'dart:math' as math;

class HealthcareDistanceService {
  double calculateDistanceKm({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const earthRadiusKm = 6371.0;

    final lat1 =
        latitude1 * math.pi / 180;

    final lat2 =
        latitude2 * math.pi / 180;

    final deltaLat =
        (latitude2 - latitude1) *
            math.pi /
            180;

    final deltaLongitude =
        (longitude2 - longitude1) *
            math.pi /
            180;

    final a =
        math.sin(deltaLat / 2) *
                math.sin(deltaLat / 2) +
            math.cos(lat1) *
                math.cos(lat2) *
                math.sin(
                  deltaLongitude / 2,
                ) *
                math.sin(
                  deltaLongitude / 2,
                );

    final c = 2 *
        math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );

    return earthRadiusKm * c;
  }
}