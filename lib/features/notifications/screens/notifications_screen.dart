import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider =
        context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
        centerTitle: true,

        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: provider.markAllAsRead,
              child: const Text(
                'Read all',
              ),
            ),
        ],
      ),

      body: provider.notifications.isEmpty
          ? const _EmptyNotifications()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount:
                  provider.notifications.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification =
                    provider.notifications[index];

                return _NotificationTile(
                  notification: notification,
                  onTap: () {
                    provider.markAsRead(
                      notification.id,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? Colors.white
          : const Color(0xFFEAF4FF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEAECF0),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  Color(0xFF172B4D),
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                                const BoxDecoration(
                              color:
                                  Color(0xFF1976D2),
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      notification.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications
    extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Color(0xFF98A2B3),
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You are all caught up.',
            style: TextStyle(
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
