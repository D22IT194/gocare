class DoctorAvailabilityModel {
  const DoctorAvailabilityModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMinutes,
    required this.isActive,
  });

  final String id;
  final String doctorId;

  /// 1 = Monday
  /// 2 = Tuesday
  /// ...
  /// 7 = Sunday
  final int dayOfWeek;

  final String startTime;
  final String endTime;

  final int slotDurationMinutes;

  final bool isActive;

  factory DoctorAvailabilityModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return DoctorAvailabilityModel(
      id: id,
      doctorId:
          map['doctorId'] as String? ?? '',
      dayOfWeek:
          (map['dayOfWeek'] as num?)?.toInt() ?? 1,
      startTime:
          map['startTime'] as String? ?? '09:00',
      endTime:
          map['endTime'] as String? ?? '17:00',
      slotDurationMinutes:
          (map['slotDurationMinutes'] as num?)
                  ?.toInt() ??
              30,
      isActive:
          map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'slotDurationMinutes':
          slotDurationMinutes,
      'isActive': isActive,
    };
  }
}