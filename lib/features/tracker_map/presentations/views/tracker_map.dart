// ignore_for_file: use_build_context_synchronously, await_only_futu

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi/core/utils/constants.dart';
import 'package:taxi/core/widgets/assets_audio_player/src/playable.dart';
import 'package:taxi/core/widgets/custom_loading_idicator.dart';
import 'package:taxi/features/chat/presentations/views/chat_view.dart';
import 'package:taxi/features/home/presentations/views_models/get_driver_cubit/get_driver_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/cache_helper.dart';
import '../../../../core/utils/magic_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../../core/widgets/custom_icon_back.dart';
import '../../../../core/widgets/custom_rating_bar.dart';
import '../../../../global_variables.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../chat/presentations/views_models/chat_cubit/cubit/chat_cubit.dart';
import '../../../home/presentations/views/canceling_reasons_view.dart';
import '../../../home/presentations/views_models/get_direction_cubit/get_direction_cubit.dart';
import '../../../home/presentations/views_models/post_details_cubit/post_details_cubit.dart';

class TrackerMapView extends StatefulWidget {
  const TrackerMapView(
      {super.key,
      required this.board,
      required this.driver,
      required this.phone,
      required this.photo,
      required this.rate,
      required this.type,
      required this.iDdriver,
      this.late,
      required this.ride,
      this.status = "beign"
      // ,required this.lat,
      // required this.lng
      });
  // final double lat;
  // final double lng;
  final String board;
  final String driver;
  final String phone;
  final String photo;
  final int rate;
  final String type;
  final String status;
  final String iDdriver;
  final dynamic late;
  final int ride;

  @override
  State<TrackerMapView> createState() => _TrackerMapViewState();
}

class _TrackerMapViewState extends State<TrackerMapView> {
  String mapTheme = '';

  void showNoteInCancelingReasons() {
    Future.delayed(Duration(minutes: 4), () {
      setState(() {
        noteShow = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    showNoteInCancelingReasons();
    GetDirectionCubit.of(context)
      ..setCustomMarker()
      ..getCurrentPositionUpdate()
      ..getReceipt()
      ..drivercancelled(context)
      ..getDriverLocation();

    if (widget.status == "beign") {
      GetDirectionCubit.of(context).driverArrived();
      GetDirectionCubit.of(context).getarrived();
    } else if (widget.status == "intheway") {
      GetDirectionCubit.of(context).changetravelstate("بدأت الرحله");
    } else if (widget.status == "pickup") {
      GetDirectionCubit.of(context).getarrived();

      GetDirectionCubit.of(context).changetravelstate("وصل الكابتين");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookRideId = PostDetailsCubit.of(context).bookRideModel?.id;
      if (bookRideId != null) {
        GetDriverCubit.of(context).getDriverDetails(bookRideId);
      }
    });
    // GetDirectionCubit.of(context).getRequest();
    // GetDirectionCubit.of(context).getDriverData();
    // GetDirectionCubit.of(context).getReceipt();
    //GetDirectionCubit.of(context).getDriverData();
    //GetDirectionCubit.of(context).driverArrived();
    //  GetDriverCubit.of(context).getDriverDetails(PostDetailsCubit.of(context).bookRideModel!.id);
    assetsAudioPlayer.open(
      Audio("assets/sounds/alert.mp3"),
      autoStart: false,
      showNotification: true,
    );
    // setCustomMarker();
    // getPolyPoints();
    // getCurrentPositionUpdate();
    DefaultAssetBundle.of(context)
        .loadString('assets/map/map_theme.json')
        .then((value) => {mapTheme = value});
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   BlocProvider.of<ChatCubit>(context).resetMessageCount();
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          /* BlocProvider(
            create: (context) => GetDirectionCubit()
              ..setCustomMarker()
              ..getCurrentPositionUpdate()
              ..getReceipt()
              ..getarrived()
              ..drivercancelled(context)
              ..getDriverLocation(),
          ),*/
          BlocProvider(
            create: (context) =>
                GetDriverCubit(), // no call here, initState handles it
          ),
          BlocProvider(
              create: (context) =>
                  ChatCubit()..getAllMessages(rideId: widget.ride)),
        ],
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              drawer: customDrawer(context),
              body: BlocConsumer<GetDirectionCubit, GetDirectionState>(
                  listener: (context, state) {
                    print("omar" + state.toString());
                  },
                  buildWhen: (previous, current) =>
                      current is GetDriverDataLoadingDone ||
                      current
                          is DirectionUpdated || // [NEW] ETA/distance refresh
                      current is GetDirectionFinish ||
                      current is GetDirectionFinish2 ||
                      current is GetDriverDataLoad ||
                      current is GetDirectionDoneRequest,
                  builder: (context, state) {
                    final cubit = GetDirectionCubit.of(context);
                    // final cubitDriverdetails = GetDriverCubit.of(context);
                    return state is GetDriverDataLoad
                        ? LoadingIndicator()
                        : SlidingUpPanel(
                            maxHeight: MediaQuery.of(context).size.height / 2.5,
                            minHeight: 125.h,
                            controller: cubit.panelController,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30.r),
                                topLeft: Radius.circular(30.r)),
                            parallaxEnabled: true,
                            body: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                GoogleMap(
                                  padding: EdgeInsets.only(bottom: 125.h),
                                  initialCameraPosition: CameraPosition(
                                    zoom: 13.5,
                                    target: currentPosition != null
                                        ? LatLng(currentPosition!.latitude,
                                            currentPosition!.longitude)
                                        : googlePlex.target,
                                  ),
                                  myLocationEnabled: false,
                                  polylines: {
                                    Polyline(
                                      polylineId: const PolylineId("route"),
                                      points: cubit.polylineCoordinates,
                                      color: kDeepBlue,
                                      width: 5,
                                    ),
                                  },
                                  markers: {
                                    if (currentPosition != null)
                                      Marker(
                                        markerId:
                                            const MarkerId("CurrentPosition"),
                                        icon: cubit.currentLocationIcon,
                                        position: LatLng(
                                            currentPosition!.latitude,
                                            currentPosition!.longitude),
                                      ),
                                    if (driverLocation != null)
                                      Marker(
                                        rotation: driverLocation!.heading,
                                        markerId: const MarkerId("destination"),
                                        icon: cubit.destinationIcon,
                                        // position: LatLng(cubit.latx,cubit.lngx),
                                        position: LatLng(
                                            driverLocation!.latitude,
                                            driverLocation!.longitude),
                                      ),
                                  },
                                  myLocationButtonEnabled: true,
                                  mapType: MapType.normal,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    controller.setMapStyle(mapTheme);
                                    cubit.controllerx.complete(controller);
                                    cubit.mapController = controller;
                                  },
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 40.h, right: 13.w),
                                  child: Builder(builder: (context) {
                                    return customIconBack(
                                      icon: Icons.menu,
                                      onTap: () async {
                                        // Timer(const Duration(seconds: 2), () { GetDirectionCubit.of(context).getDriverData();});
                                        Scaffold.of(context).openDrawer();
                                      },
                                    );
                                  }),
                                ),
                                if (cubit.currentDistance.isNotEmpty)
                                  Positioned(
                                    top: 40.h,
                                    left: 13.w,
                                    child: BlocBuilder<GetDirectionCubit,
                                        GetDirectionState>(
                                      buildWhen: (p, c) =>
                                          c is DirectionUpdated,
                                      builder: (context, state) {
                                        final c = GetDirectionCubit.of(context);
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            boxShadow: const [
                                              BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2))
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _InfoTile(
                                                icon: Icons.directions_car,
                                                label: 'Distance',
                                                value: c.currentDistance,
                                              ),
                                              Container(
                                                width: 1,
                                                height: 36.h,
                                                color: Colors.grey[300],
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                              ),
                                              _InfoTile(
                                                icon: Icons.access_time,
                                                label: 'ETA',
                                                value: c.currentDuration,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(
                                  height: 20.h,
                                ),
                              ],
                            ),
                            panel: BlocProvider.value(
                              value: cubit,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    top: 10.h,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 40.0,
                                        right: 40,
                                      ),
                                      child: SizedBox(
                                        width: 300.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 5,
                                              width: 30.w,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              15.r)),
                                                  color: Colors.grey),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // ignore: unnecessary_null_comparison
                                                widget.photo == null
                                                    ? Container(
                                                        width: 80.w,
                                                        height: 80.w,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Image.asset(
                                                            'assets/images/user.png'))
                                                    : Container(
                                                        width: 80.w,
                                                        height: 80.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: NetworkImage(
                                                                widget.photo),
                                                          ),
                                                        )),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                Text(
                                                  widget.driver,
                                                  style: FontStyles.textStyle18,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            TravelState(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    widget.type,
                                                    style: FontStyles
                                                        .textStyle15
                                                        .copyWith(
                                                            color: kBlack,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                  ),
                                                  SizedBox(
                                                    width: 100.w,
                                                  ),
                                                  Container(
                                                    height: 30.h,
                                                    width: 70.w,
                                                    decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xffD5DDE0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16)),
                                                    child: Center(
                                                        child: Text(
                                                            widget.board,
                                                            style: FontStyles
                                                                .textStyle15
                                                                .copyWith(
                                                                    color:
                                                                        kBlack))),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20.h,
                                            ),
                                            CustomRatingBar(
                                                rate: widget.rate.toDouble()),
                                            SizedBox(
                                              height: 30.h,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 120.w,
                                                  child: CustomButton(
                                                    borderColor: kDeepBlue,
                                                    text: LocaleKeys
                                                        .contactDriver
                                                        .tr(),
                                                    textColor: kDeepBlue,
                                                    backgroundColor: kWhite,
                                                    onPressed: () => launch(
                                                        'tel://${widget.phone}'),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                BlocBuilder<ChatCubit,
                                                    ChatState>(
                                                  builder: (context, state) {
                                                    final cubit =
                                                        ChatCubit.get(context);
                                                    // final driver = cubit.isDriver(
                                                    //     driverId: widget.iDdriver);
                                                    // int messageCount = cubit
                                                    //         .messages.isNotEmpty
                                                    //     ? cubit.messages.length
                                                    //     : 0;
                                                    return Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        SizedBox(
                                                          width: 80.w,
                                                          child: CustomButton(
                                                              borderColor:
                                                                  Colors.green,
                                                              text: LocaleKeys
                                                                  .chat
                                                                  .tr(),
                                                              textColor:
                                                                  Colors.green,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                MagicRouter
                                                                    .navigateTo(
                                                                        ChatView(
                                                                  driverName:
                                                                      widget
                                                                          .driver,
                                                                  rideId: widget
                                                                      .ride,
                                                                ));
                                                                cubit
                                                                    .resetMessageCount();

                                                                // if (cubit.messages
                                                                //         .isNotEmpty &&
                                                                //     cubit.messages.any(
                                                                //         (message) =>
                                                                //             message
                                                                //                 .userId
                                                                //                 .toString() ==
                                                                //             widget
                                                                //                 .iDdriver)) {
                                                                //   print(
                                                                //       'At least one message has the userId equal to widget.iDdriver');
                                                                // } else {
                                                                //   print(
                                                                //       'No message has the userId equal to widget.iDdriver');
                                                                // }
                                                              }),
                                                        ),
                                                        // cubit.messages.any((message) =>
                                                        //             message.userId
                                                        //                 .toString() ==
                                                        //             widget.iDdriver
                                                        //                 .toString())

                                                        cubit.messages.isNotEmpty &&
                                                                cubit.messages.any((message) =>
                                                                    message
                                                                        .userId !=
                                                                    CacheHelper.getData(
                                                                            key:
                                                                                'userId')
                                                                        .toString())
                                                            ? Positioned(
                                                                right: -4,
                                                                top: -8,
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      shape: BoxShape
                                                                          .circle),
                                                                  width: 20.w,
                                                                  height: 20.h,
                                                                ))
                                                            : SizedBox()
                                                      ],
                                                    );
                                                  },
                                                ),
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                SizedBox(
                                                  width: 80.w,
                                                  child: CustomButton(
                                                    borderColor:
                                                        const Color(0xff980011),
                                                    text:
                                                        LocaleKeys.cancel.tr(),
                                                    textColor:
                                                        const Color(0xff980011),
                                                    backgroundColor:
                                                        Colors.white,
                                                    onPressed: () =>
                                                        MagicRouter.navigateTo(
                                                            const CancelingReasonsView()),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                  })),
        ));
  }
}

class TravelState extends StatelessWidget {
  const TravelState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetDirectionCubit, GetDirectionState>(
      builder: (context, state) {
        print("ooooo" + state.travelState);
        return Text(
          state.travelState,
          style: FontStyles.textStyle18,
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: kDeepBlue, size: 20.r),
        SizedBox(height: 3.h),
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ],
    );
  }
}
