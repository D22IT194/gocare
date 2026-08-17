import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<NotificationProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text('Notifications'),
        // centerTitle: true,
        scrolledUnderElevation: 0,

        actions: [
          // if (provider.hasUnread)
          //   PopupMenuButton<String>(
          //     onSelected: (value) {
          //       if (value == 'read_all') {
          //         provider.markAllAsRead();
          //       }
          //     },
          //     itemBuilder: (_) => const [
          //       PopupMenuItem(
          //         value: 'read_all',
          //         child: Row(
          //           children: [
          //             Icon(Icons.done_all, size: 20),
          //             SizedBox(width: 10),
          //             Text('Mark all as read'),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),

          // if (provider.notifications.isNotEmpty)
          //   PopupMenuButton<String>(
          //     onSelected: (value) {
          //       if (value == 'delete_all') {
          //         _confirmDeleteAll(context, provider);
          //       }
          //     },
          //     itemBuilder: (_) => const [
          //       PopupMenuItem(
          //         value: 'delete_all',
          //         child: Row(
          //           children: [
          //             Icon(Icons.delete_outline, size: 20),
          //             SizedBox(width: 10),
          //             Text('Delete all'),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
        ],
      ),

      body: provider.isLoading
          ? const _NotificationsSkeleton()
          : Column(
              children: [
                // _NotificationSummary(
                //   unreadCount: provider.unreadCount,
                //   totalCount: provider.notifications.length,
                // ),

                // const SizedBox(height: 4),

                _NotificationFilters(
                  selectedFilter: provider.selectedFilter,
                  unreadCount: provider.unreadCount,
                  readCount: provider.readCount,
                  onChanged: provider.setFilter,
                ),

                const SizedBox(height: 2),

                Expanded(
                  child: _NotificationList(
                    notifications: provider.visibleNotifications,
                    onTap: (notification) {
                      _handleNotificationTap(context, notification);
                    },
                    onDelete: (notification) {
                      provider.deleteNotification(notification.id);
                    },
                    onToggleRead: (notification) {
                      provider.toggleRead(notification.id);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    final provider = context.read<NotificationProvider>();

    provider.markAsRead(notification.id);

    // ==========================================================
    // Future dynamic navigation
    // ==========================================================
    //
    // Later we can use notification.type + notification.targetId
    // to navigate to:
    //
    // EmergencyScreen
    // AppointmentDetailScreen
    // DoctorDetailScreen
    // HospitalDetailScreen
    // BlogDetailScreen
    // FirstAidDetailScreen
    //
    // For now, mark the notification as read only.
  }

  // Future<void> _confirmDeleteAll(
  //   BuildContext context,
  //   NotificationProvider provider,
  // ) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Delete all notifications?'),
  //         content: const Text(
  //           'All notifications will be removed from this list.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context, false);
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           FilledButton(
  //             onPressed: () {
  //               Navigator.pop(context, true);
  //             },
  //             child: const Text('Delete all'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirmed == true) {
  //     provider.deleteAll();
  //   }
  // }
}

// ================================================================
// SUMMARY
// ================================================================

// class _NotificationSummary extends StatelessWidget {
//   const _NotificationSummary({
//     required this.unreadCount,
//     required this.totalCount,
//   });

//   final int unreadCount;
//   final int totalCount;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFEAF4FF),
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: const Color(0xFFD8EAFE)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 46,
//               height: 46,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.notifications_active_outlined,
//                 color: Color(0xFF1976D2),
//               ),
//             ),

//             const SizedBox(width: 12),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     unreadCount == 0
//                         ? 'You are all caught up'
//                         : '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF172B4D),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '$totalCount notification${totalCount == 1 ? '' : 's'}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF667085),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ================================================================
// FILTERS
// ================================================================

class _NotificationFilters extends StatelessWidget {
  const _NotificationFilters({
    required this.selectedFilter,
    required this.unreadCount,
    required this.readCount,
    required this.onChanged,
  });

  final NotificationFilter selectedFilter;
  final int unreadCount;
  final int readCount;

  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            count: unreadCount + readCount,
            selected: selectedFilter == NotificationFilter.all,
            onTap: () {
              onChanged(NotificationFilter.all);
            },
          ),

          const SizedBox(width: 8),

          _FilterChip(
            label: 'Unread',
            count: unreadCount,
            selected: selectedFilter == NotificationFilter.unread,
            onTap: () {
              onChanged(NotificationFilter.unread);
            },
          ),

          const SizedBox(width: 8),

          _FilterChip(
            label: 'Read',
            count: readCount,
            selected: selectedFilter == NotificationFilter.read,
            onTap: () {
              onChanged(NotificationFilter.read);
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF1976D2) : Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF344054),
                ),
              ),

              const SizedBox(width: 7),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF667085),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LIST
// ================================================================

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.notifications,
    required this.onTap,
    required this.onDelete,
    required this.onToggleRead,
  });

  final List<NotificationModel> notifications;

  final ValueChanged<NotificationModel> onTap;

  final ValueChanged<NotificationModel> onDelete;

  final ValueChanged<NotificationModel> onToggleRead;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _EmptyNotifications();
    }

    return RefreshIndicator(
      onRefresh: () {
        return context.read<NotificationProvider>().refresh();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        itemCount: notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Dismissible(
            key: ValueKey(notification.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) async {
              onDelete(notification);
              return true;
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 22),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: _NotificationTile(
              notification: notification,
              onTap: () {
                onTap(notification);
              },
              onDelete: () {
                onDelete(notification);
              },
              onToggleRead: () {
                onToggleRead(notification);
              },
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// NOTIFICATION TILE
// ================================================================

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.onToggleRead,
  });

  final NotificationModel notification;

  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleRead;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead ? Colors.white : const Color(0xFFEAF4FF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                type: notification.type,
                isRead: notification.isRead,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF172B4D),
                            ),
                          ),
                        ),

                        if (!notification.isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 5),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1976D2),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        notification.type.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: Color(0xFF98A2B3),
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            notification.time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF98A2B3),
                            ),
                          ),
                        ),

                        // PopupMenuButton<String>(
                        //   padding: EdgeInsets.zero,
                        //   constraints: const BoxConstraints(
                        //     minWidth: 36,
                        //     minHeight: 36,
                        //   ),
                        //   icon: const Icon(
                        //     Icons.more_horiz,
                        //     color: Color(0xFF98A2B3),
                        //   ),
                        //   onSelected: (value) {
                        //     switch (value) {
                        //       case 'read':
                        //         onToggleRead();
                        //         break;

                        //       case 'delete':
                        //         onDelete();
                        //         break;
                        //     }
                        //   },
                        //   itemBuilder: (_) => [
                        //     PopupMenuItem(
                        //       value: 'read',
                        //       child: Text(
                        //         notification.isRead
                        //             ? 'Mark as unread'
                        //             : 'Mark as read',
                        //       ),
                        //     ),
                        //     const PopupMenuItem(
                        //       value: 'delete',
                        //       child: Text('Delete'),
                        //     ),
                        //   ],
                        // ),
                      ],
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

// ================================================================
// ICON
// ================================================================

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, required this.isRead});

  final NotificationType type;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (type) {
      case NotificationType.general:
        icon = Icons.notifications_outlined;
        break;

      case NotificationType.emergency:
        icon = Icons.emergency_outlined;
        break;

      case NotificationType.appointment:
        icon = Icons.calendar_month_outlined;
        break;

      case NotificationType.doctor:
        icon = Icons.person_search_outlined;
        break;

      case NotificationType.hospital:
        icon = Icons.local_hospital_outlined;
        break;

      case NotificationType.health:
        icon = Icons.favorite_border;
        break;

      case NotificationType.firstAid:
        icon = Icons.medical_services_outlined;
        break;

      case NotificationType.blog:
        icon = Icons.article_outlined;
        break;

      case NotificationType.recommendation:
        icon = Icons.recommend_outlined;
        break;

      case NotificationType.system:
        icon = Icons.settings_outlined;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFFF2F4F7) : const Color(0xFFDCEEFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: isRead ? const Color(0xFF667085) : const Color(0xFF1976D2),
        size: 23,
      ),
    );
  }
}

// ================================================================
// EMPTY
// ================================================================

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationProvider>();

    String title;
    String message;
    IconData icon;

    switch (provider.selectedFilter) {
      case NotificationFilter.all:
        icon = Icons.notifications_none;
        title = 'No notifications';
        message = 'You are all caught up.';

        break;

      case NotificationFilter.unread:
        icon = Icons.done_all;
        title = 'No unread notifications';
        message = 'You have read all your notifications.';

        break;

      case NotificationFilter.read:
        icon = Icons.mark_email_unread_outlined;
        title = 'No read notifications';
        message = 'Read notifications will appear here.';

        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: const Color(0xFF1976D2)),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// SKELETON
// ================================================================

class _NotificationsSkeleton extends StatefulWidget {
  const _NotificationsSkeleton();

  @override
  State<_NotificationsSkeleton> createState() => _NotificationsSkeletonState();
}

class _NotificationsSkeletonState extends State<_NotificationsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({double? width, required double height, double radius = 8}) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D5DD),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  Widget _tile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(width: 48, height: 48, radius: 14),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 150, height: 15),

                const SizedBox(height: 10),

                _box(width: double.infinity, height: 11),

                const SizedBox(height: 7),

                _box(width: 210, height: 11),

                const SizedBox(height: 10),

                _box(width: 80, height: 9),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 82,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF4FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _box(width: 46, height: 46, radius: 23),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 170, height: 13),
                    const SizedBox(height: 7),
                    _box(width: 90, height: 9),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            _box(width: 70, height: 36, radius: 20),
            const SizedBox(width: 8),
            _box(width: 85, height: 36, radius: 20),
            const SizedBox(width: 8),
            _box(width: 70, height: 36, radius: 20),
          ],
        ),

        const SizedBox(height: 16),

        _tile(),

        const SizedBox(height: 10),

        _tile(),

        const SizedBox(height: 10),

        _tile(),

        const SizedBox(height: 10),

        _tile(),
      ],
    );
  }
}
