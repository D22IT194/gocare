import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'gocare_downloads';
  static const String _channelName = 'GoCare Downloads';

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final permission = await androidImplementation
        ?.requestNotificationsPermission();

    debugPrint('NOTIFICATION PERMISSION: $permission');

    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Notifications for GoCare downloaded files',
        importance: Importance.max,
      ),
    );

    _initialized = true;

    debugPrint('========================================');
    debugPrint('GOCare NOTIFICATION SERVICE READY');
    debugPrint('========================================');
  }

  // ============================================================
  // NOTIFICATION CLICK
  // ============================================================

static Future<void> _onNotificationTapped(
  NotificationResponse response,
) async {
  try {
    final payload = response.payload;

    debugPrint('========================================');
    debugPrint('DOWNLOAD NOTIFICATION CLICKED');
    debugPrint('PAYLOAD: $payload');
    debugPrint('========================================');

    if (payload == null || payload.trim().isEmpty) {
      debugPrint('NOTIFICATION PAYLOAD IS EMPTY');
      return;
    }

    final parts = payload.split('|||');

    if (parts.length < 2) {
      debugPrint('INVALID NOTIFICATION PAYLOAD');
      return;
    }

    final uri = parts[0].trim();
    final mimeType = parts[1].trim();

    debugPrint('EXTRACTED URI: $uri');
    debugPrint('EXTRACTED MIME: $mimeType');

    await openDownloadedFile(
      uri: uri,
      mimeType: mimeType,
    );
  } catch (e, stackTrace) {
    debugPrint('NOTIFICATION CLICK ERROR: $e');
    debugPrint('$stackTrace');
  }
}

  // ============================================================
  // SHOW DOWNLOAD NOTIFICATION
  // ============================================================

  static Future<void> showDownloadNotification({
    required String title,
    required String body,
    required String uri,
    required String mimeType,
  }) async {
    try {
      await initialize();

      if (!Platform.isAndroid) {
        return;
      }

      final cleanUri = uri.trim();

      if (cleanUri.isEmpty) {
        debugPrint('NOTIFICATION NOT SENT: EMPTY URI');
        return;
      }

      final payload = '$cleanUri|||$mimeType';

      debugPrint('========================================');
      debugPrint('DOWNLOAD NOTIFICATION');
      debugPrint('TITLE: $title');
      debugPrint('BODY: $body');
      debugPrint('URI: $cleanUri');
      debugPrint('MIME: $mimeType');
      debugPrint('========================================');

      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final enabled = await androidImplementation?.areNotificationsEnabled();

      debugPrint('NOTIFICATIONS ENABLED: $enabled');

      if (enabled != true) {
        debugPrint('NOTIFICATION BLOCKED BY ANDROID');
        return;
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Notifications for GoCare downloaded files',
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: true,
        ongoing: false,
        enableVibration: true,
        playSound: true,
        category: AndroidNotificationCategory.status,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );

      await _plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );

      debugPrint('========================================');
      debugPrint('DOWNLOAD NOTIFICATION SENT');
      debugPrint('NOTIFICATION ID: $notificationId');
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint('DOWNLOAD NOTIFICATION ERROR: $e');
      debugPrint('$stackTrace');
    }
  }

  // ============================================================
  // OPEN DOWNLOADED MEDIASTORE FILE
  // ============================================================

  static Future<void> openDownloadedFile({
    required String uri,
    required String mimeType,
  }) async {
    try {
      if (!Platform.isAndroid) {
        return;
      }

      final cleanUri = uri.trim();

      if (cleanUri.isEmpty) {
        debugPrint('OPEN FILE: EMPTY URI');
        return;
      }

      debugPrint('========================================');
      debugPrint('OPEN DOWNLOADED FILE');
      debugPrint('URI: $cleanUri');
      debugPrint('MIME TYPE: $mimeType');
      debugPrint('========================================');

      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: cleanUri,
        type: mimeType,
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_ACTIVITY_CLEAR_TOP,
          Flag.FLAG_GRANT_READ_URI_PERMISSION,
        ],
      );

      debugPrint('LAUNCHING FILE VIEW INTENT...');

      await intent.launch();

      debugPrint('FILE VIEW INTENT LAUNCHED');
    } catch (e, stackTrace) {
      debugPrint('OPEN DOWNLOADED FILE ERROR: $e');
      debugPrint('$stackTrace');
    }
  }
}
