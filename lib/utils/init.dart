import 'package:u/utilities.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

abstract class UCore {
  static late String apiKey;
  static late String fcmToken;
  static bool isDialogOpen = false;
}

Future<void> initUtilities({
  final FirebaseOptions? firebaseOptions,
  final String? channelId,
  final String? channelName,
  required final String notificationIcon,
  final Color easyLoadingPrimaryColor = Colors.blue,
  final bool safeDevice = false,
  final bool protectDataLeaking = false,
  final bool preventScreenShot = false,
  final List<DeviceOrientation> deviceOrientations = const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ],
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(deviceOrientations);
  await ULocalStorage.init();
  UApp.packageInfo = await PackageInfo.fromPlatform();
  if (UApp.isAndroid) UApp.androidDeviceInfo = await UApp.deviceInfo.androidInfo;
  if (UApp.isIos) UApp.iosDeviceInfo = await UApp.deviceInfo.iosInfo;
  if (UApp.isWeb) UApp.webBrowserInfo = await UApp.deviceInfo.webBrowserInfo;
  if (UApp.isWindows) UApp.windowsDeviceInfo = await UApp.deviceInfo.windowsInfo;
  if (UApp.isMacOs) UApp.macOsDeviceInfo = await UApp.deviceInfo.macOsInfo;
  if (UApp.isLinux) UApp.linuxDeviceInfo = await UApp.deviceInfo.linuxInfo;
  if (firebaseOptions != null) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);

      // مقداردهی Local Notifications
      await UFirebase.initializeNotifications(
        channelId: channelId?? '',
        channelName: channelName?? '',
        notificationIcon: notificationIcon,
      );

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (final Object error, final StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack);
        return true;
      };
    } catch (e) {}
  }
  try {
    if (protectDataLeaking) await ScreenProtector.protectDataLeakageWithColor(Colors.white);
    if (preventScreenShot) await ScreenProtector.preventScreenshotOn();
  } catch (e) {}

  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.dualRing
    ..indicatorSize = 45.0
    ..radius = 10.1
    ..progressColor = easyLoadingPrimaryColor
    ..backgroundColor = Colors.transparent
    ..indicatorColor = easyLoadingPrimaryColor
    ..textColor = Colors.transparent
    ..maskColor = Colors.blue
    ..maskType = EasyLoadingMaskType.black
    ..loadingStyle = EasyLoadingStyle.custom
    ..userInteractions = false
    ..boxShadow = <BoxShadow>[]
    ..dismissOnTap = false;
}

class UMaterialApp extends StatefulWidget {
  const UMaterialApp({
    required this.localizationsDelegates,
    required this.supportedLocales,
    required this.locale,
    required this.lightTheme,
    required this.darkTheme,
    required this.home,
    super.key,
  });

  final List<LocalizationsDelegate<dynamic>> localizationsDelegates;
  final List<Locale> supportedLocales;
  final Locale locale;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Widget home;

  @override
  State<UMaterialApp> createState() => _UMaterialAppState();
}

class _UMaterialAppState extends State<UMaterialApp> {

  @override
  void initState() {
    UFirebase.getFcmToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        navigatorObservers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
        enableLog: false,
        localizationsDelegates: widget.localizationsDelegates,
        supportedLocales: widget.supportedLocales,
        home: widget.home,
        locale: Locale(ULocalStorage.getString(UConstants.locale) ?? widget.locale.languageCode),
        theme: widget.lightTheme,
        darkTheme: widget.darkTheme,
        themeMode: (ULocalStorage.getBool(UConstants.isDarkMode) ?? false) ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          if (kDebugMode) {
            debugPrint("Builder called. Locale: ${Localizations.localeOf(context)}");
          }
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.86)),
            child: EasyLoading.init()(context, child),
          );
        },
      );
}
