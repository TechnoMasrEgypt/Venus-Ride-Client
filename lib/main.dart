import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/core/widgets/wakelock/wackelock.dart';
import 'package:taxi/features/home/presentations/views_models/Check_ride_cubit/check_ride_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/get_driver_cubit/get_driver_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/notfication_cubit/cubit/notfication_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/post_details_cubit/post_details_cubit.dart';
import 'package:taxi/features/splash/presentation/views/splash_view.dart';
import 'package:taxi/firebase_options.dart';
import 'package:taxi/translations/codegen_loader.g.dart';
import 'core/utils/bloc_observer.dart';
import 'core/utils/cache_helper.dart';
import 'core/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/utils/internet_connection_error.dart';
import 'core/utils/magic_router.dart';
import 'core/utils/network_info.dart';
import 'features/auth/presentation/views_models/login_cubit/login_cubit.dart';
import 'features/home/presentations/views_models/cancel_search_cubit/cancelled_search_cubit.dart';
import 'features/home/presentations/views_models/get_direction_cubit/get_direction_cubit.dart';
import 'features/home/presentations/views_models/profile_cubit/profile_cubit.dart';
import 'features/home/presentations/views_models/promo_code_cubit/promo_code_cubit.dart';
import 'features/home/presentations/views_models/rate_model/rate_cubit.dart';

//.....................firebase messaging...............//

//.....................firebase messaging...............//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  await Firebase.initializeApp(
    name: 'VenusDriver',
    options: DefaultFirebaseOptionsCaptin.currentPlatform,
  );
  setupPushNotifications();




  await EasyLocalization.ensureInitialized();
  //.....................firebase messaging...............//


  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications',
    bypassDnd: true,// title
    // description
    importance: Importance.max,
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel id',
              'channel name',
              ongoing: true,
              visibility: NotificationVisibility.public,
              showWhen: true,
              enableLights: true,
              channelBypassDnd: true,
              channelDescription: 'channel description',
              priority: Priority.high,
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ));
    }
  });
  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      assetLoader: const CodegenLoader(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: DevicePreview(
          enabled: false,
          builder: (_)=>Taxi())));
  Bloc.observer = AppBlocObserver();
  await CacheHelper.init();
}
Future<void> setupPushNotifications() async {


  // 🔐 Ask for permission
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {

    // ⚠️ Wait a moment to let APNs token be registered
    await Future.delayed(Duration(seconds: 1));

    // 📬 Get the APNs token (iOS only)
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('📬 APNs Token: $apnsToken');

    // 📲 Now get FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('📲 FCM Token: $fcmToken');
  } else {
    print('❌ Permission denied');
  }
}
class Taxi extends StatefulWidget {
  const Taxi({Key? key}) : super(key: key);

  @override
  State<Taxi> createState() => _TaxiState();
}

class _TaxiState extends State<Taxi> {
  // cheek internet
  Map _source = {ConnectivityResult.none: false};
  @override
  void initState() {
    NetworkConnectivity.instance.initialise();
    NetworkConnectivity.instance.myStream.listen((source) {
      _source = source;
      log('source $_source');
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          _source.values.toList()[0]
              ? log('Network Connection')
              : MagicRouter.navigateTo(const InternetConnectionError());
          break;
        case ConnectivityResult.wifi:
          _source.values.toList()[0]
              ? log('Network Connection')
              : MagicRouter.navigateTo(const InternetConnectionError());
          break;
        case ConnectivityResult.none:
        default:
          MagicRouter.navigateTo(const InternetConnectionError());
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => LoginCubit(),
            ),
            BlocProvider(
              create: (context) => ProfileCubit()..getProfileDetails(),
            ),
            BlocProvider(
              create: (context) => GetDirectionCubit(),
            ),
            BlocProvider(
              create: (context) => PostDetailsCubit(),
            ),
            BlocProvider(
              create: (context) => CancelledSearchCubit(),
            ),
            BlocProvider(
              create: (context) => GetDriverCubit(),
            ),
            BlocProvider(
              create: (context) => CheckRideCubit(),
            ),
            BlocProvider(
              create: (context) => RateCubit(),
            ),
            BlocProvider(
              create: (context) => PromoCodeCubit(),
            ),
            BlocProvider(
              create: (context) => NotficationCubit(),
            ),
          ],
          child: MaterialApp(
            home: const SplashView(),
            navigatorKey: navigatorKey,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: kCairo,
              scaffoldBackgroundColor: kWhite,
            ),
          ),
        );
      },
    );
  }
}
