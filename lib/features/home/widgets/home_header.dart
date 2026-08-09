import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.onNotificationPressed,
  });

  final String name;
  final VoidCallback onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'How can we help you today?',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      color:
                          const Color(0xFF667085),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onNotificationPressed,
          tooltip: 'Notifications',
          style: IconButton.styleFrom(
            backgroundColor:
                const Color(0xFFF2F4F7),
          ),
          icon: const Icon(
            Icons.notifications_none,
          ),
        ),
      ],
    );
  }
}