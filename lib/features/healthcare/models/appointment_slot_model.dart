class AppointmentSlotModel {
  const AppointmentSlotModel({
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  final String startTime;
  final String endTime;
  final bool isBooked;

  bool get isAvailable => !isBooked;
}