import 'package:u/utilities.dart';

abstract class UFirebase {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling a background message: ${message.messageId}');
  }

  /// use [setupFirebaseMessaging] in main Rout page
  static void setupFirebaseMessaging({
    required String channelId,
    required String channelName,
    Function(RemoteMessage message)? onReceiveNotificationWhenInApp,
    required Function(RemoteMessage message) onMessageOpenedApp,
    required Future<void> Function(RemoteMessage message) onBackgroundMessageReceive,
  }) async {
    final messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      settings.authorizationStatus == AuthorizationStatus.authorized ? "User granted permission" : "User declined or has not granted permission",
    );

    if (UApp.isIos) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageReceive);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        // await _showNotification(message);
        await UNotification.showLocalNotification(
          message,
          channelId: channelId,
          channelName: channelName,
          onReceiveNotificationWhenInApp: onReceiveNotificationWhenInApp,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked!");
      onMessageOpenedApp(message);
    });
  }

  static Future<void> getFcmToken() async {
    final messaging = FirebaseMessaging.instance;

    // Get FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      debugPrint("Firebase Messaging Token: $token");
      UCore.fcmToken = token;
    }
  }

// Initialize Local Notifications
  static Future<void> initializeNotifications({
    required String channelId,
    required String channelName,
    required String notificationIcon,
  }) async {
    // String? _notificationIcon = '@drawable/ic_status_bar_icon';
    String _notificationIcon = notificationIcon;
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(_notificationIcon);
    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
          // Core.selectNotificationStream.add(notificationResponse.payload);
          // push(NotificationPage());
            break;
          case NotificationResponseType.selectedNotificationAction:
          // برای زمانی که نوتیفیکیشن دکمه اکشن داشته باشد

          // if (notificationResponse.actionId == Core.navigationActionId) {
          //   Core.selectNotificationStream.add(notificationResponse.payload);
          // }

            break;
        }
      },
    );

    // Create Notification Channel
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }
}
