import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/features/home/presentations/views_models/get_driver_cubit/get_driver_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/notfication_cubit/cubit/notfication_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/post_details_cubit/post_details_cubit.dart';
import 'package:taxi/features/splash/presentation/views/splash_view.dart';
import 'package:taxi/firebase_options.dart';
import 'package:taxi/translations/codegen_loader.g.dart';
import 'package:wakelock/wakelock.dart';
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
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}

//.....................firebase messaging...............//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    // name: 'VenusClient',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Firebase.initializeApp(
    name: 'VenusDriver',
    options: DefaultFirebaseOptionsCaptin.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();
  //.....................firebase messaging...............//
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  log('User granted permission: ${settings.authorizationStatus}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
    }
  });
  //.....................firebase messaging...............//
  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      assetLoader: const CodegenLoader(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const Taxi()));
  Bloc.observer = AppBlocObserver();
  await CacheHelper.init();
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
