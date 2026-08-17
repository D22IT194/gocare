enum HealthcareFacilityType {
  hospital,
  clinic,
  diagnosticCenter,
  pharmacy,
}

class HealthcareFacilityModel {
  const HealthcareFacilityModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.address,
    required this.city,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isSponsored,
    required this.isEmergencyAvailable,
    required this.isOpen24Hours,
    required this.appointmentEnabled,
    required this.specialities,
    required this.doctorCount,
  });

  final String id;
  final String name;

  final HealthcareFacilityType type;

  final String description;
  final String address;
  final String city;
  final String phone;

  final double latitude;
  final double longitude;

  final String imageUrl;

  final double rating;
  final int reviewCount;

  final bool isVerified;
  final bool isSponsored;

  final bool isEmergencyAvailable;
  final bool isOpen24Hours;
  final bool appointmentEnabled;

  final List<String> specialities;

  final int doctorCount;

  factory HealthcareFacilityModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return HealthcareFacilityModel(
      id: id,
      name: map['name'] ?? '',
      type: _parseType(
        map['type'],
      ),
      description:
          map['description'] ?? '',
      address:
          map['address'] ?? '',
      city:
          map['city'] ?? '',
      phone:
          map['phone'] ?? '',
      latitude:
          (map['latitude'] ?? 0)
              .toDouble(),
      longitude:
          (map['longitude'] ?? 0)
              .toDouble(),
      imageUrl:
          map['imageUrl'] ?? '',
      rating:
          (map['rating'] ?? 0)
              .toDouble(),
      reviewCount:
          (map['reviewCount'] ?? 0)
              .toInt(),
      isVerified:
          map['isVerified'] ?? false,
      isSponsored:
          map['isSponsored'] ?? false,
      isEmergencyAvailable:
          map['isEmergencyAvailable'] ??
              false,
      isOpen24Hours:
          map['isOpen24Hours'] ??
              false,
      appointmentEnabled:
          map['appointmentEnabled'] ??
              false,
      specialities:
          List<String>.from(
        map['specialities'] ?? [],
      ),
      doctorCount:
          (map['doctorCount'] ?? 0)
              .toInt(),
    );
  }

  static HealthcareFacilityType
      _parseType(
    dynamic value,
  ) {
    switch (value) {
      case 'clinic':
        return HealthcareFacilityType
            .clinic;

      case 'diagnosticCenter':
        return HealthcareFacilityType
            .diagnosticCenter;

      case 'pharmacy':
        return HealthcareFacilityType
            .pharmacy;

      default:
        return HealthcareFacilityType
            .hospital;
    }
  }

  String get typeLabel {
    switch (type) {
      case HealthcareFacilityType.hospital:
        return 'Hospital';

      case HealthcareFacilityType.clinic:
        return 'Clinic';

      case HealthcareFacilityType.diagnosticCenter:
        return 'Diagnostic Center';

      case HealthcareFacilityType.pharmacy:
        return 'Pharmacy';
    }
  }
}