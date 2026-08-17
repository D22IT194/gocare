import '../models/appointment_slot_model.dart';
import '../models/doctor_availability_model.dart';

class AppointmentSlotService {
  static List<AppointmentSlotModel>
      generateSlots({
    required DoctorAvailabilityModel
        availability,
    required Set<String> bookedSlots,
  }) {
    final start =
        _parseTime(
      availability.startTime,
    );

    final end =
        _parseTime(
      availability.endTime,
    );

    final duration =
        availability
            .slotDurationMinutes;

    final slots =
        <AppointmentSlotModel>[];

    var current = start;

    while (
        current + duration <= end) {
      final startTime =
          _formatTime(current);

      final endTime =
          _formatTime(
        current + duration,
      );

      slots.add(
        AppointmentSlotModel(
          startTime: startTime,
          endTime: endTime,
          isBooked:
              bookedSlots.contains(
            startTime,
          ),
        ),
      );

      current += duration;
    }

    return slots;
  }

  static int _parseTime(
    String value,
  ) {
    final parts =
        value.split(':');

    final hour =
        int.tryParse(parts[0]) ?? 0;

    final minute =
        int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  static String _formatTime(
    int totalMinutes,
  ) {
    final hour =
        totalMinutes ~/ 60;

    final minute =
        totalMinutes % 60;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}