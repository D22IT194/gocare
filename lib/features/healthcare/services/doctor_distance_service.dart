import 'dart:math';

class DoctorDistanceService {
  static double calculateKm({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const earthRadius = 6371.0;

    final lat1 =
        _toRadians(latitude1);

    final lat2 =
        _toRadians(latitude2);

    final deltaLat =
        _toRadians(
      latitude2 - latitude1,
    );

    final deltaLon =
        _toRadians(
      longitude2 - longitude1,
    );

    final a =
        pow(sin(deltaLat / 2), 2) +
        cos(lat1) *
            cos(lat2) *
            pow(
              sin(deltaLon / 2),
              2,
            );

    final c =
        2 *
            atan2(
              sqrt(a),
              sqrt(1 - a),
            );

    return earthRadius * c;
  }

  static double _toRadians(
    double degree,
  ) {
    return degree * pi / 180;
  }
}