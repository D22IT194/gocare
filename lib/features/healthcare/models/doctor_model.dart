class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialityId,
    required this.specialityName,
    required this.qualification,
    required this.experienceYears,
    required this.about,
    required this.profileImageUrl,
    required this.phone,
    required this.clinicName,
    required this.clinicAddress,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.isVerified,
    required this.isFeatured,
    required this.isSponsored,
    required this.isActive,
    required this.appointmentEnabled,
    required this.facilityIds
  });

  final String id;
  final String name;

  final String specialityId;
  final String specialityName;

  final String qualification;
  final int experienceYears;
  final String about;

  final String profileImageUrl;
  final String phone;

  final String clinicName;
  final String clinicAddress;

  final double latitude;
  final double longitude;

  final double rating;
  final int reviewCount;

  final double consultationFee;

  final bool isVerified;
  final bool isFeatured;
  final bool isSponsored;
  final bool isActive;
  final bool appointmentEnabled;
  final List<String> facilityIds;

  factory DoctorModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return DoctorModel(
      id: id,
      name: map['name'] as String? ?? '',
      specialityId:
          map['specialityId'] as String? ?? '',
      specialityName:
          map['specialityName'] as String? ?? '',
      qualification:
          map['qualification'] as String? ?? '',
      experienceYears:
          (map['experienceYears'] as num?)?.toInt() ?? 0,
      about: map['about'] as String? ?? '',
      profileImageUrl:
          map['profileImageUrl'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      clinicName:
          map['clinicName'] as String? ?? '',
      clinicAddress:
          map['clinicAddress'] as String? ?? '',
      latitude:
          (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude:
          (map['longitude'] as num?)?.toDouble() ?? 0,
      rating:
          (map['rating'] as num?)?.toDouble() ?? 0,
      reviewCount:
          (map['reviewCount'] as num?)?.toInt() ?? 0,
      consultationFee:
          (map['consultationFee'] as num?)
                  ?.toDouble() ??
              0,
      isVerified:
          map['isVerified'] as bool? ?? false,
      isFeatured:
          map['isFeatured'] as bool? ?? false,
      isSponsored:
          map['isSponsored'] as bool? ?? false,
      isActive:
          map['isActive'] as bool? ?? true,
      appointmentEnabled:
          map['appointmentEnabled'] as bool? ??
              false,
      facilityIds: List<String>.from(
           map['facilityIds'] ?? const [],
),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialityId': specialityId,
      'specialityName': specialityName,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'about': about,
      'profileImageUrl': profileImageUrl,
      'phone': phone,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'reviewCount': reviewCount,
      'consultationFee': consultationFee,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'isSponsored': isSponsored,
      'isActive': isActive,
      'appointmentEnabled': appointmentEnabled,
    };
  }
}