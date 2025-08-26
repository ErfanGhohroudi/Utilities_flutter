import 'package:u/utilities.dart';
import 'package:http/http.dart' as http;

class UNotification {
  UNotification._();

  static Future<Uint8List?> _getByteArrayFromUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final http.Response response = await http.get(uri);
    return response.bodyBytes;
  }

  static Future<void> showLocalNotification(
    RemoteMessage message, {
    required String channelId,
    required String channelName,
    Function(RemoteMessage message)? onReceiveNotificationWhenInApp,
  }) async {
    final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
    RemoteNotification? notification = message.notification;
    if (kDebugMode) {
      print("notif data => ${message.data.toString()}");
    }

    if (onReceiveNotificationWhenInApp != null) {
      // Core.notificationsCount(Core.notificationsCount.value + 1);
      onReceiveNotificationWhenInApp(message);
    }

    BigPictureStyleInformation? bigPictureStyleInformation;
    ByteArrayAndroidBitmap? largeIcon;

    if (message.data["image"] != null) {
      largeIcon = await _getByteArrayFromUrl(message.data["image"]) != null ? ByteArrayAndroidBitmap((await _getByteArrayFromUrl(message.data["image"]))!) : null;

      // final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
      //     await _getByteArrayFromUrl(message.data["image"]));
      //
      // bigPictureStyleInformation = BigPictureStyleInformation(
      //   bigPicture,
      //   largeIcon: largeIcon,
      //   // contentTitle: 'عنوان با تصویر',
      //   contentTitle: 'overridden <b>big</b> content title',
      //   // summaryText: 'این تصویر از سمت بک‌اند دریافت شده است.',
      //   summaryText: 'summary <i>text</i>',
      //   hideExpandedLargeIcon: false,
      // );
    }

    if (notification != null) {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'This channel is used for important notifications.',
        largeIcon: largeIcon,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
        ticker: 'ticker',
        // actions: <AndroidNotificationAction>[
        //   AndroidNotificationAction(
        //     'id_1',
        //     'Action 1',
        //   ),
        //   AndroidNotificationAction(
        //     'id_2',
        //     'Action 2',
        //     titleColor: Colors.red,
        //   ),
        //   AndroidNotificationAction(
        //     'id_3',
        //     'Action 3',
        //     showsUserInterface: true,
        //     // By default, Android plugin will dismiss the notification when the
        //     // user tapped on a action (this mimics the behavior on iOS).
        //     // cancelNotification: false,
        //   ),
        // ],
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            // presentBanner: true,
            // presentList: true,
          ));

      await notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(),
      );
    }
  }
}
