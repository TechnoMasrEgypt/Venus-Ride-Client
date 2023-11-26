// ignore_for_file: use_build_context_synchronously, await_only_futures, deprecated_member_use
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi/core/utils/constants.dart';
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
      required this.ride
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
          BlocProvider(
            create: (context) => GetDirectionCubit()
              ..setCustomMarker()
              ..getCurrentPositionUpdate()
              ..getReceipt()
              ..drivercancelled(context)
              ..getDriverLocation(),
          ),
          BlocProvider(
            create: (context) => GetDriverCubit()
              ..getDriverDetails(
                  PostDetailsCubit.of(context).bookRideModel!.id),
          ),
          BlocProvider(
              create: (context) =>
                  ChatCubit()..getAllMessages(rideId: widget.ride)),
        ],
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              drawer: customDrawer(context),
              body: BlocBuilder<GetDirectionCubit, GetDirectionState>(
                  builder: (context, state) {
                final cubit = GetDirectionCubit.of(context);
                // final cubitDriverdetails = GetDriverCubit.of(context);
                return State is GetDriverDataLoad
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
                                target: LatLng(currentPosition.latitude,
                                    currentPosition.longitude),
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
                                Marker(
                                  markerId: const MarkerId("CurrentPosition"),
                                  icon: cubit.currentLocationIcon,
                                  position: LatLng(currentPosition.latitude,
                                      currentPosition.longitude),
                                ),
                                Marker(
                                  rotation: driverLocation.heading,
                                  markerId: const MarkerId("destination"),
                                  icon: cubit.destinationIcon,
                                  // position: LatLng(cubit.latx,cubit.lngx),
                                  position: LatLng(driverLocation.latitude,
                                      driverLocation.longitude),
                                ),
                              },
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                              onMapCreated: (GoogleMapController controller) {
                                controller.setMapStyle(mapTheme);
                                cubit.controllerx.complete(controller);
                                cubit.mapController = controller;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 40.h, right: 13.w),
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
                            SizedBox(
                              height: 20.h,
                            ),
                          ],
                        ),
                        panelBuilder: (ScrollController scroll) {
                          return Stack(
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
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15.r)),
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
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Image.asset(
                                                        'assets/images/user.png'))
                                                : Container(
                                                    width: 80.w,
                                                    height: 80.w,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
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
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                widget.type,
                                                style: FontStyles.textStyle15
                                                    .copyWith(
                                                        color: kBlack,
                                                        fontWeight:
                                                            FontWeight.w700),
                                              ),
                                              SizedBox(
                                                width: 100.w,
                                              ),
                                              Container(
                                                height: 30.h,
                                                width: 70.w,
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xffD5DDE0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                child: Center(
                                                    child: Text(widget.board,
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
                                                text: LocaleKeys.contactDriver
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
                                            BlocBuilder<ChatCubit, ChatState>(
                                              builder: (context, state) {
                                                final cubit =
                                                    ChatCubit.get(context);
                                                final driver = cubit.isDriver(
                                                    driverId: widget.iDdriver);
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
                                                          text: 'Chat',
                                                          textColor:
                                                              Colors.green,
                                                          backgroundColor:
                                                              Colors.white,
                                                          onPressed: () {
                                                            MagicRouter
                                                                .navigateTo(
                                                                    ChatView(
                                                              driverName:
                                                                  widget.driver,
                                                              rideId:
                                                                  widget.ride,
                                                            ));
                                                            cubit
                                                                .resetMessageCount();
                                                          }),
                                                    ),
                                                    // cubit.messages.any((message) =>
                                                    //             message.userId
                                                    //                 .toString() ==
                                                    //             widget.iDdriver
                                                    //                 .toString())
                                                    driver &&
                                                            cubit.messages
                                                                .isNotEmpty
                                                        ? Positioned(
                                                            right: -4,
                                                            top: -8,
                                                            child: Container(
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
                                                text: LocaleKeys.cancel.tr(),
                                                textColor:
                                                    const Color(0xff980011),
                                                backgroundColor: Colors.white,
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
                          );
                        },
                      );
              })),
        ));
  }
}
