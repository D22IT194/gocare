enum NotificationType {
  general,
  emergency,
  appointment,
  doctor,
  hospital,
  health,
  firstAid,
  blog,
  recommendation,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.general:
        return 'General';

      case NotificationType.emergency:
        return 'Emergency';

      case NotificationType.appointment:
        return 'Appointment';

      case NotificationType.doctor:
        return 'Doctor';

      case NotificationType.hospital:
        return 'Hospital';

      case NotificationType.health:
        return 'Health';

      case NotificationType.firstAid:
        return 'First Aid';

      case NotificationType.blog:
        return 'Health Blog';

      case NotificationType.recommendation:
        return 'Recommendation';

      case NotificationType.system:
        return 'System';
    }
  }
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.type = NotificationType.general,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  final NotificationType type;

  /// Optional actual creation time.
  ///
  /// `time` is still kept because your existing data
  /// already uses strings such as "2 hours ago".
  final DateTime? createdAt;

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotificationType? type,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}