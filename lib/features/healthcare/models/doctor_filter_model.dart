class DoctorFilterModel {
  const DoctorFilterModel({
    this.maxDistanceKm,
    this.minRating,
    this.minExperienceYears,
    this.maxConsultationFee,
    this.availableToday = false,
    this.verifiedOnly = false,
    this.appointmentAvailable = false,
  });

  final double? maxDistanceKm;
  final double? minRating;
  final int? minExperienceYears;
  final double? maxConsultationFee;

  final bool availableToday;
  final bool verifiedOnly;
  final bool appointmentAvailable;

  DoctorFilterModel copyWith({
    double? maxDistanceKm,
    double? minRating,
    int? minExperienceYears,
    double? maxConsultationFee,
    bool? availableToday,
    bool? verifiedOnly,
    bool? appointmentAvailable,
    bool clearDistance = false,
    bool clearRating = false,
    bool clearExperience = false,
    bool clearFee = false,
  }) {
    return DoctorFilterModel(
      maxDistanceKm: clearDistance
          ? null
          : maxDistanceKm ?? this.maxDistanceKm,
      minRating: clearRating
          ? null
          : minRating ?? this.minRating,
      minExperienceYears:
          clearExperience
              ? null
              : minExperienceYears ??
                  this.minExperienceYears,
      maxConsultationFee:
          clearFee
              ? null
              : maxConsultationFee ??
                  this.maxConsultationFee,
      availableToday:
          availableToday ??
              this.availableToday,
      verifiedOnly:
          verifiedOnly ??
              this.verifiedOnly,
      appointmentAvailable:
          appointmentAvailable ??
              this.appointmentAvailable,
    );
  }

  bool get hasFilters {
    return maxDistanceKm != null ||
        minRating != null ||
        minExperienceYears != null ||
        maxConsultationFee != null ||
        availableToday ||
        verifiedOnly ||
        appointmentAvailable;
  }

  int get activeFilterCount {
    int count = 0;

    if (maxDistanceKm != null) count++;
    if (minRating != null) count++;
    if (minExperienceYears != null) count++;
    if (maxConsultationFee != null) count++;
    if (availableToday) count++;
    if (verifiedOnly) count++;
    if (appointmentAvailable) count++;

    return count;
  }

  static const empty =
      DoctorFilterModel();
}