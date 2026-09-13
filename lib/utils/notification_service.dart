import 'package:flutter/foundation.dart';

import 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.html) 'stub/firebase_messaging_stub.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'stub/flutter_local_notifications_stub.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ── Lazily created — never touched on web ───────────────────────
  FirebaseMessaging? _fcm;
  FlutterLocalNotificationsPlugin? _localNotifications;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'student_result_channel',
    'Student Result Notifications',
    description: 'Notifications for student results and alerts',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // Web: Firebase Messaging is not supported — exit immediately
    if (kIsWeb) return;

    try {
      // Only create instances on non-web platforms
      _fcm = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();

      await _fcm!.requestPermission(alert: true, badge: true, sound: true);

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _localNotifications!.initialize(initSettings);

      await _localNotifications!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      FirebaseMessaging.onMessage.listen(_showLocalNotification);

      final token = await _fcm!.getToken();
      debugPrint('FCM Token: $token');
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    if (kIsWeb || _localNotifications == null) return;
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (kIsWeb || _localNotifications == null) return;
    await _localNotifications!.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showLowGpaWarning(String studentName, double gpa) async {
    if (kIsWeb) return;
    await showLocalNotification(
      title: '⚠️ Low GPA Alert',
      body:
          '$studentName has a GPA of ${gpa.toStringAsFixed(2)}. Needs attention!',
      id: studentName.hashCode,
    );
  }

  Future<void> showResultPublished(String studentName) async {
    if (kIsWeb) return;
    await showLocalNotification(
      title: '🎉 Result Published',
      body: 'Result for $studentName has been published.',
      id: studentName.hashCode + 1,
    );
  }
}
