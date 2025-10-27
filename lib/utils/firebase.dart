import 'package:u/utilities.dart';

class UFirebase {
  UFirebase._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   if (kDebugMode) {
  //     print('Handling a background message: ${message.messageId}');
  //   }
  // }

  /// use [setupFirebaseMessaging] in main Rout page
  static void setupFirebaseMessaging({
    required String channelId,
    required String channelName,
    required String? icon,
    required Function(RemoteMessage message) onMessageOpenedApp,
    required Future<void> Function(RemoteMessage message) onBackgroundMessageReceive,
    Function(RemoteMessage message)? onReceiveNotificationWhenInApp,
  }) async {
    final messaging = FirebaseMessaging.instance;

    // Request notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print(
        settings.authorizationStatus == AuthorizationStatus.authorized ? "User granted permission" : "User declined or has not granted permission",
      );
    }

    if (UApp.isIos) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // FirebaseMessaging.onBackgroundMessage(onBackgroundMessageReceive);

    // ۱. بررسی باز شدن اپ از حالت کاملاً بسته (Terminated)
    messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print("App opened from TERMINATED state by a notification!");
        }
        onMessageOpenedApp(message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        // await _showNotification(message);
        await UNotification.showLocalNotification(
          message,
          channelId: channelId,
          channelName: channelName,
          icon: icon,
          onReceiveNotificationWhenInApp: onReceiveNotificationWhenInApp,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Notification clicked!");
      }
      onMessageOpenedApp(message);
    });
  }

  static Future<void> getFcmToken() async {
    final messaging = FirebaseMessaging.instance;

    // Get FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      if (kDebugMode) {
        print("Firebase Messaging Token: $token");
      }
      UCore.fcmToken = token;
    }
  }

// Initialize Local Notifications
  static Future<void> initializeNotifications({
    required String channelId,
    required String channelName,

    /// example: '@drawable/ic_status_bar_icon'
    required String notificationIcon,
    required Function(NotificationResponse notificationResponse) onNotificationTap,
  }) async {
    // android settings
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(notificationIcon);

    // iOS settings
    final DarwinInitializationSettings initializationSettingsDarwin = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
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
