// Web stub — replaces flutter_local_notifications on web builds.
// All methods are no-ops so the app compiles and runs on Chrome.

class FlutterLocalNotificationsPlugin {
  Future<bool?> initialize(InitializationSettings settings) async => true;

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? details,
  ) async {}

  T? resolvePlatformSpecificImplementation<T extends Object>() => null;
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<void> createNotificationChannel(
      AndroidNotificationChannel channel) async {}
}

class AndroidNotificationChannel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  const AndroidNotificationChannel(
    this.id,
    this.name, {
    this.description = '',
    this.importance = Importance.high,
  });
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(
    String channelId,
    String channelName, {
    String? channelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
    String? icon,
  });
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails();
}

class NotificationDetails {
  const NotificationDetails({
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
  });
}

class InitializationSettings {
  const InitializationSettings({
    AndroidInitializationSettings? android,
    DarwinInitializationSettings? iOS,
  });
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String defaultIcon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({
    bool requestAlertPermission = false,
    bool requestBadgePermission = false,
    bool requestSoundPermission = false,
  });
}

class Importance {
  static const Importance high = Importance._(3);
  final int value;
  const Importance._(this.value);
}

class Priority {
  static const Priority high = Priority._(1);
  final int value;
  const Priority._(this.value);
}
