// Web stub — replaces firebase_messaging on web builds.
// All methods are no-ops so the app compiles and runs on Chrome.

class FirebaseMessaging {
  static final FirebaseMessaging instance = FirebaseMessaging._();
  FirebaseMessaging._();

  Future<void> requestPermission({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) async {}

  Future<String?> getToken() async => null;

  static Stream<RemoteMessage> get onMessage => const Stream.empty();
}

class RemoteMessage {
  RemoteNotification? get notification => null;
}

class RemoteNotification {
  final String? title;
  final String? body;
  const RemoteNotification({this.title, this.body});
}
