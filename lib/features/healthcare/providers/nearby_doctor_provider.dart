import 'package:flutter/foundation.dart';

import '../models/nearby_doctor_model.dart';
import '../services/doctor_service.dart';

class NearbyDoctorProvider
    extends ChangeNotifier {
  NearbyDoctorProvider({
    DoctorService? service,
  }) : _service =
            service ?? DoctorService();

  final DoctorService _service;

  List<NearbyDoctorModel> _doctors = [];

  bool _loading = false;

  String? _error;

  double? _latitude;
  double? _longitude;

  double _radiusKm = 25;

  List<NearbyDoctorModel>
      get doctors =>
          List.unmodifiable(
        _doctors,
      );

  bool get loading => _loading;

  String? get error => _error;

  double get radiusKm =>
      _radiusKm;

  Future<void> loadNearbyDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
  }) async {
    _loading = true;
    _error = null;

    _latitude = latitude;
    _longitude = longitude;
    _radiusKm = radiusKm;

    notifyListeners();

    try {
      _doctors =
          await _service
              .getNearbyDoctors(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
    } catch (error) {
      _error =
          error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _doctors = [];
    _error = null;
    notifyListeners();
  }
}