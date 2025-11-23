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

  /// Get FCM token with retry logic and error handling
  /// Retries up to 3 times with exponential backoff if SERVICE_NOT_AVAILABLE error occurs
  /// Returns true if token was successfully retrieved, false otherwise
  static Future<bool> getFcmToken({int maxRetries = 3}) async {
    // Check if Firebase is initialized
    try {
      Firebase.app();
    } catch (e) {
      if (kDebugMode) {
        print("Firebase is not initialized. Cannot get FCM token.");
      }
      return false;
    }

    // Add initial delay to ensure service is ready
    await Future.delayed(const Duration(milliseconds: 500));

    final messaging = FirebaseMessaging.instance;
    int attempt = 0;
    bool success = false;

    while (attempt < maxRetries && !success) {
      try {
        attempt++;

        if (kDebugMode && attempt > 1) {
          print("Attempting to get FCM token (attempt $attempt/$maxRetries)...");
        }

        // Get FCM token
        String? token = await messaging.getToken();

        if (token != null && token.isNotEmpty) {
          if (kDebugMode) {
            print("Firebase Messaging Token retrieved successfully: $token");
          }
          UCore.fcmToken = token;
          success = true;
        } else {
          if (kDebugMode) {
            print("FCM token is null or empty");
          }
          throw Exception("FCM token is null or empty");
        }
      } catch (e) {
        final errorMessage = e.toString();
        final isServiceNotAvailable =
            errorMessage.contains('SERVICE_NOT_AVAILABLE') || errorMessage.contains('SERVICE_NOT_AVAILABLE') || errorMessage.contains('IOException');

        if (kDebugMode) {
          print("Error getting FCM token (attempt $attempt/$maxRetries): $errorMessage");
        }

        // If it's SERVICE_NOT_AVAILABLE and we have retries left, wait and retry
        if (isServiceNotAvailable && attempt < maxRetries) {
          // Exponential backoff: 1s, 2s, 4s
          final delaySeconds = 1 * (1 << (attempt - 1));
          if (kDebugMode) {
            print("SERVICE_NOT_AVAILABLE error. Retrying in ${delaySeconds}s...");
          }
          await Future.delayed(Duration(seconds: delaySeconds));
        } else {
          // If it's not SERVICE_NOT_AVAILABLE or we've exhausted retries, log and return
          if (kDebugMode) {
            print("Failed to get FCM token after $attempt attempts. Error: $errorMessage");
          }
          // Record error to Crashlytics if available
          try {
            FirebaseCrashlytics.instance.recordError(
              e,
              StackTrace.current,
              reason: 'Failed to get FCM token after $attempt attempts',
            );
          } catch (_) {
            // Crashlytics might not be available, ignore
          }
          break;
        }
      }
    }

    if (!success && kDebugMode) {
      print("Could not retrieve FCM token after $maxRetries attempts. This might be due to:");
      print("- Google Play Services not available or outdated");
      print("- No internet connection");
      print("- Firebase Messaging service not ready");
    }

    return success;
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
