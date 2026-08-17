import 'package:flutter/material.dart';

import '../models/appointment_model.dart';

class AppointmentStatusChip
    extends StatelessWidget {
  const AppointmentStatusChip({
    super.key,
    required this.status,
  });

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final config =
        _config(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight:
              FontWeight.w800,
          color: config.foreground,
        ),
      ),
    );
  }

  _StatusConfig _config(
    AppointmentStatus status,
  ) {
    switch (status) {
      case AppointmentStatus.pending:
        return const _StatusConfig(
          label: 'Pending',
          background:
              Color(0xFFFFF4E5),
          foreground:
              Color(0xFFB54708),
        );

      case AppointmentStatus.confirmed:
        return const _StatusConfig(
          label: 'Confirmed',
          background:
              Color(0xFFECFDF3),
          foreground:
              Color(0xFF027A48),
        );

      case AppointmentStatus.cancelled:
        return const _StatusConfig(
          label: 'Cancelled',
          background:
              Color(0xFFFEF3F2),
          foreground:
              Color(0xFFB42318),
        );

      case AppointmentStatus.completed:
        return const _StatusConfig(
          label: 'Completed',
          background:
              Color(0xFFF2F4F7),
          foreground:
              Color(0xFF475467),
        );

      case AppointmentStatus.rejected:
        return const _StatusConfig(
          label: 'Rejected',
          background:
              Color(0xFFFEF3F2),
          foreground:
              Color(0xFFB42318),
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}