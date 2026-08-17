import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';

enum NotificationFilter {
  all,
  unread,
  read,
}

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Welcome to GoCare',
      message:
          'Your GoCare account is ready. Stay safe and take care.',
      time: 'Just now',
      type: NotificationType.general,
    ),

    NotificationModel(
      id: '2',
      title: 'First Aid Reminder',
      message:
          'Learn basic first aid procedures to be prepared for emergencies.',
      time: '2 hours ago',
      type: NotificationType.firstAid,
    ),

    NotificationModel(
      id: '3',
      title: 'Emergency Contacts',
      message:
          'Make sure your emergency contacts are updated.',
      time: 'Yesterday',
      type: NotificationType.emergency,
    ),

    NotificationModel(
      id: '4',
      title: 'Health Information',
      message:
          'Keep your health information updated for faster emergency assistance.',
      time: 'Yesterday',
      isRead: true,
      type: NotificationType.health,
    ),

    NotificationModel(
      id: '5',
      title: 'Health Blog',
      message:
          'New health information is available. Check the latest articles.',
      time: '2 days ago',
      isRead: true,
      type: NotificationType.blog,
    ),
  ];

  NotificationFilter _selectedFilter =
      NotificationFilter.all;

  bool _isLoading = false;

  NotificationFilter get selectedFilter =>
      _selectedFilter;

  bool get isLoading => _isLoading;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount =>
      _notifications.where(
        (notification) => !notification.isRead,
      ).length;

  int get readCount =>
      _notifications.where(
        (notification) => notification.isRead,
      ).length;

  bool get hasUnread => unreadCount > 0;

  List<NotificationModel> get visibleNotifications {
    switch (_selectedFilter) {
      case NotificationFilter.all:
        return List.unmodifiable(
          _notifications,
        );

      case NotificationFilter.unread:
        return List.unmodifiable(
          _notifications.where(
            (notification) =>
                !notification.isRead,
          ),
        );

      case NotificationFilter.read:
        return List.unmodifiable(
          _notifications.where(
            (notification) =>
                notification.isRead,
          ),
        );
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void setFilter(NotificationFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }

    _selectedFilter = filter;

    notifyListeners();
  }

  // ============================================================
  // MARK SINGLE AS READ
  // ============================================================

  void markAsRead(String id) {
    final index = _notifications.indexWhere(
      (notification) =>
          notification.id == id,
    );

    if (index == -1) {
      return;
    }

    final notification =
        _notifications[index];

    if (notification.isRead) {
      return;
    }

    _notifications[index] =
        notification.copyWith(
      isRead: true,
    );

    notifyListeners();
  }

  // ============================================================
  // MARK SINGLE AS UNREAD
  // ============================================================

  void markAsUnread(String id) {
    final index = _notifications.indexWhere(
      (notification) =>
          notification.id == id,
    );

    if (index == -1) {
      return;
    }

    final notification =
        _notifications[index];

    if (!notification.isRead) {
      return;
    }

    _notifications[index] =
        notification.copyWith(
      isRead: false,
    );

    notifyListeners();
  }

  // ============================================================
  // TOGGLE READ
  // ============================================================

  void toggleRead(String id) {
    final index = _notifications.indexWhere(
      (notification) =>
          notification.id == id,
    );

    if (index == -1) {
      return;
    }

    final notification =
        _notifications[index];

    _notifications[index] =
        notification.copyWith(
      isRead: !notification.isRead,
    );

    notifyListeners();
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  void markAllAsRead() {
    if (!hasUnread) {
      return;
    }

    for (int i = 0;
        i < _notifications.length;
        i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] =
            _notifications[i].copyWith(
          isRead: true,
        );
      }
    }

    notifyListeners();
  }

  // ============================================================
  // MARK ALL AS UNREAD
  // ============================================================

  void markAllAsUnread() {
    if (_notifications.isEmpty) {
      return;
    }

    for (int i = 0;
        i < _notifications.length;
        i++) {
      if (_notifications[i].isRead) {
        _notifications[i] =
            _notifications[i].copyWith(
          isRead: false,
        );
      }
    }

    notifyListeners();
  }

  // ============================================================
  // DELETE
  // ============================================================

  void deleteNotification(String id) {
    _notifications.removeWhere(
      (notification) =>
          notification.id == id,
    );

    notifyListeners();
  }

  // ============================================================
  // DELETE ALL
  // ============================================================

  void deleteAll() {
    if (_notifications.isEmpty) {
      return;
    }

    _notifications.clear();

    notifyListeners();
  }

  // ============================================================
  // ADD
  // ============================================================

  void addNotification(
    NotificationModel notification,
  ) {
    _notifications.removeWhere(
      (item) => item.id == notification.id,
    );

    _notifications.insert(
      0,
      notification,
    );

    notifyListeners();
  }

  // ============================================================
  // REFRESH
  //
  // Currently the notifications are local/static.
  // This method is intentionally ready for Firestore/API
  // implementation later.
  // ============================================================

  Future<void> refresh() async {
    _isLoading = true;

    notifyListeners();

    try {
      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      // TODO:
      // Replace this with Firestore/API loading
      // when notifications become dynamic.
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }
}