import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    const NotificationModel(
      id: '1',
      title: 'Welcome to GoCare',
      message:
          'Your GoCare account is ready. Stay safe and take care.',
      time: 'Just now',
    ),
    const NotificationModel(
      id: '2',
      title: 'First Aid Reminder',
      message:
          'Learn basic first aid procedures to be prepared for emergencies.',
      time: '2 hours ago',
    ),
    const NotificationModel(
      id: '3',
      title: 'Emergency Contacts',
      message:
          'Make sure your emergency contacts are updated.',
      time: 'Yesterday',
    ),
  ];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where((item) => !item.isRead).length;

  bool get hasUnread => unreadCount > 0;

  void markAsRead(String id) {
    final index = _notifications.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) {
      return;
    }

    if (_notifications[index].isRead) {
      return;
    }

    _notifications[index] =
        _notifications[index].copyWith(
      isRead: true,
    );

    notifyListeners();
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] =
          _notifications[i].copyWith(
        isRead: true,
      );
    }

    notifyListeners();
  }

  void addNotification(
    NotificationModel notification,
  ) {
    _notifications.insert(
      0,
      notification,
    );

    notifyListeners();
  }
}