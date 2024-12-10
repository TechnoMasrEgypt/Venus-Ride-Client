import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:taxi/core/utils/cache_helper.dart';
import 'package:taxi/core/utils/magic_router.dart';
import 'package:taxi/core/widgets/custom_text_form.dart';
import 'package:taxi/features/after_splash/presentations/views/after_splash_view.dart';
import 'package:taxi/features/home/presentations/views/widgets/spinner.dart';
import 'package:taxi/features/home/presentations/views_models/get_direction_cubit/get_direction_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/get_driver_cubit/get_driver_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/post_details_cubit/post_details_cubit.dart';
import 'package:taxi/features/home/presentations/views_models/promo_code_cubit/promo_code_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../global_variables.dart';
import '../../../../../translations/locale_keys.g.dart';
import '../../views_models/rate_model/rate_cubit.dart';
import '../canceling_reasons_view.dart';
import 'contact_us_view_body.dart';

Set<Marker> markersList = {};
Future<dynamic> buildShowModalBottomSheet(BuildContext context,
    {required String title,
    required String leftBtnText,
    required String rightBtnText,
    required void Function()? rightBtnFunc}) {
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0.r),
        topRight: Radius.circular(16.0.r),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(30.0),
      child: SizedBox(
        height: 215.h,
        child: Column(
          children: [
            Text(
              title,
              style: FontStyles.textStyle18,
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 144.w,
                  child: CustomButton(
                    text: leftBtnText,
                    textColor: kWhite,
                    backgroundColor: kDeepBlue,
                    onPressed: () => MagicRouter.pop(),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffDDDDDD),
                        blurRadius: 7.0,
                        spreadRadius: 4.0,
                        offset: Offset(0.0, 3.0),
                      )
                    ],
                  ),
                  width: 144.w,
                  child: CustomButton(
                      text: rightBtnText,
                      textColor: kBlack,
                      backgroundColor: kWhite,
                      onPressed: rightBtnFunc),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> buildSearchModalBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0.r),
        topRight: Radius.circular(16.0.r),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 600.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                shadowColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(12..w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.circle,
                                color: kDeepBlue,
                                size: 16.w,
                              ),
                              Container(
                                width: 1.2.w,
                                height: 50.h,
                                color: const Color(0xff3E4958),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xff4B545A),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          SizedBox(
                            width: 255.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextField(
                                  controller: currentLocationController,
                                  decoration: InputDecoration(
                                      suffixIcon: InkWell(
                                          onTap: () {
                                            currentLocationController
                                                .setText(currentLocation);
                                          },
                                          child: const Icon(
                                            Icons.location_on_outlined,
                                            color: kDeepBlue,
                                          )),
                                      hintText: '24, Ocean avenue',
                                      hintStyle: FontStyles.textStyle15,
                                      focusedBorder: const UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: kDeepBlue)),
                                      contentPadding: EdgeInsets.zero),
                                  cursorColor: kDeepBlue,
                                ),
                                TextField(
                                  enabled: false,
                                  controller: destinationController,
                                  decoration: InputDecoration(
                                    hintText: LocaleKeys.destination.tr(),
                                    hintStyle: FontStyles.textStyle15,
                                    contentPadding: EdgeInsets.zero,
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: kDeepBlue)),
                                  ),
                                  cursorColor: kDeepBlue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 18.h,
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: kDeepBlue,
                  ),
                ),
                InkWell(
                    onTap: () => MagicRouter.pop(),
                    child: Text(
                      LocaleKeys.showOnMap.tr(),
                      style: FontStyles.textStyle15.copyWith(color: kDeepBlue),
                    ))
              ],
            ),
            SizedBox(
              height: 18.h,
            ),
            Text(
              LocaleKeys.recent.tr(),
              style:
                  FontStyles.textStyle13.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 18.h,
            ),

            //  Lottie.asset('assets/json/manwaitingcar.json'),
            Center(
                child: Text(LocaleKeys.noRecentTripyet.tr(),
                    style: FontStyles.textStyle15)),
            // Expanded(
            //   child: ListView.builder(
            //       physics: const BouncingScrollPhysics(),
            //       itemBuilder: (context, index) => const RecentListTile(),
            //       itemCount: 4),
            // ),
            SizedBox(
              height: 18.h,
            ),
            Center(
                child: BlocListener<GetDirectionCubit, GetDirectionState>(
              listener: (context, state) {},
              child: CustomButton(
                  backgroundColor: kDeepBlue,
                  text: LocaleKeys.confirm.tr(),
                  textColor: kWhite,
                  onPressed: () async {
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult != ConnectivityResult.mobile &&
                        connectivityResult != ConnectivityResult.wifi) {
                      showSnackBar(
                        LocaleKeys.noInternetConnectivity.tr(),
                      );
                    }
                    if (destinationController.text == '') {
                      /* showSnackBar('Enter the destination please'
                          //   LocaleKeys.noInternetConnectivity.tr(),
                          );*/
                      print(100);
                      /* ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Enter the destination please'),
                        ),
                      );*/
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              Localizations.localeOf(context).languageCode ==
                                      'en'
                                  ? 'Warring'
                                  : " تحذير",
                              style: TextStyle(color: Colors.red),
                            ),
                            content: Text(
                              Localizations.localeOf(context).languageCode ==
                                      'en'
                                  ? 'Enter the destination please'
                                  : " يرجي تحديد وجهتك",
                              style: TextStyle(fontSize: 15),
                              // textAlign: TextAlign.center,
                            ),
                            actions: [
                              TextButton(
                                child: Text(Localizations.localeOf(context)
                                            .languageCode ==
                                        'en'
                                    ? 'OK'
                                    : "تم"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      MagicRouter.pop();
                      buildBookRideShowModalBottomSheet(context);
                    }

                    // print(getDirectionCubit.notificationDetails!.ride);
                    //print(getDirectionCubit.notificationDetails!.driver);
                    // print(getDirectionCubit.notificationDetails!.lat);
                    // print(getDirectionCubit.notificationDetails!.lng);
                  }),
            )),
            SizedBox(
              height: 18.h,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> buildBookRideShowModalBottomSheet(BuildContext context) {
  final postCubit = PostDetailsCubit.of(context);
  final getDirectionCubit = GetDirectionCubit.of(context);
  final promoCodeCubit = PromoCodeCubit.of(context);
//  TextEditingController controller = TextEditingController();
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0.r),
        topRight: Radius.circular(16.0.r),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.all(20.0.w),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            height: 350,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocListener<PromoCodeCubit, PromoCodeState>(
                    listener: (context, state) {},
                    child: BlocBuilder<PromoCodeCubit, PromoCodeState>(
                      builder: (BuildContext context, state) {
                        return state is SendMsgLoaded
                            ? Column(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: SpinImage(
                                      imageUrl: AppAssets.loadingimage,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    LocaleKeys.wait.tr(),
                                    style: FontStyles.textStyle18,
                                  ),
                                ],
                              )
                            : Card(
                                elevation: 4,
                                shadowColor: Colors.blueGrey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: EdgeInsets.all(16..w),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          AppAssets.bookCar,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                promoCodeCubit.promoCodeModel !=
                                                        null
                                                    ? getDirectionCubit.testNull
                                                        ? Text('')
                                                        : Text(
                                                            "${postCubit.estimateFares(getDirectionCubit.directionDetails!) - ((postCubit.estimateFares(getDirectionCubit.directionDetails!)) * (double.parse(promoCodeCubit.promoCodeModel!.coupon.value) / 100))}",
                                                            style: FontStyles
                                                                .textStyle15,
                                                          )
                                                    : getDirectionCubit.testNull
                                                        ? Text('')
                                                        : Text(
                                                            "${postCubit.estimateFares(getDirectionCubit.directionDetails!)}",
                                                            style: FontStyles
                                                                .textStyle15,
                                                          ),
                                                Text(LocaleKeys.dinar.tr(),
                                                    style: FontStyles
                                                        .textStyle13
                                                        .copyWith(
                                                            color: kBlack,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(1),
                                              width: 70.w,
                                              //height: 80,
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xffD5DDE0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              child: getDirectionCubit.testNull
                                                  ? Text('')
                                                  : Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      '${getDirectionCubit.directionDetails!.durationText} ',
                                                      style: FontStyles
                                                          .textStyle15
                                                          .copyWith(
                                                              color: kWhite,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  BlocListener<PromoCodeCubit, PromoCodeState>(
                    listener: (BuildContext context, state) {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200.w,
                          child: customTextField(
                              color: const Color(0xffD5DDE0),
                              hintText: LocaleKeys.promoCode.tr(),
                              isPassword: false,
                              type: TextInputType.text,
                              controller: promoCodeCubit.couponController),
                        ),
                        SizedBox(
                            width: 80.w,
                            height: 48.h,
                            child: CustomButton(
                              text: LocaleKeys.active.tr(),
                              textColor: kWhite,
                              backgroundColor: kDeepBlue,
                              onPressed: () => promoCodeCubit.promoCode(),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  getDirectionCubit.testNull
                      ? Center(
                          child: Text(
                          LocaleKeys
                              .thedistanceislongyoushouldchooseaclosedestination
                              .tr(),
                          style: FontStyles.textStyle15,
                        ))
                      : Center(child:
                          BlocBuilder<PostDetailsCubit, PostDetailsState>(
                          builder: (context, state) {
                            return state is PostDetailsLoading
                                ? Column(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: SpinImage(
                                          imageUrl: AppAssets.loadingimage,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        LocaleKeys.wait.tr(),
                                        style: FontStyles.textStyle18,
                                      ),
                                    ],
                                  )
                                : CustomButton(
                                    backgroundColor: kDeepBlue,
                                    text: LocaleKeys.bookRide.tr(),
                                    textColor: kWhite,
                                    onPressed: () async {
                                      setState(() {
                                        getDirectionCubit.testNull = false;
                                      });
                                      var connectivityResult =
                                          await (Connectivity()
                                              .checkConnectivity());
                                      if (connectivityResult !=
                                              ConnectivityResult.mobile &&
                                          connectivityResult !=
                                              ConnectivityResult.wifi) {
                                        showSnackBar(
                                          LocaleKeys.noInternetConnectivity
                                              .tr(),
                                        );
                                      }
                                      postCubit.postData(
                                        startRide: getDirectionCubit
                                            .directionDetails!.startAddress!,
                                        endRide: getDirectionCubit
                                            .directionDetails!.endAddress!,
                                        currentLat: currentPosition.latitude,
                                        currentLong: currentPosition.longitude,
                                        dLat: destinationPosition.latitude,
                                        dLong: destinationPosition.longitude,
                                        cost: postCubit.estimateFares(
                                            getDirectionCubit
                                                .directionDetails!),
                                        distance: getDirectionCubit
                                            .directionDetails!.distanceText!,
                                        time: getDirectionCubit
                                            .directionDetails!.durationText!,
                                        coupunId: promoCodeCubit
                                            .promoCodeModel?.coupon.id,
                                      );
                                      getDirectionCubit
                                          .changetravelstate("وافق السائق");

                                      getDirectionCubit.driverArrived();
                                      //getDirectionCubit.drivercancelled(context);
                                      // MagicRouter.navigateTo(const SearchingCarView())
                                      log(
                                        getDirectionCubit
                                            .directionDetails!.durationText!,
                                      );
                                      log(
                                        getDirectionCubit
                                            .directionDetails!.endAddress!,
                                      );
                                    },
                                  );
                          },
                        ))
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

Future<dynamic> buildBookRideShowModalBottomSheetWithoutDes(
    BuildContext context) {
  final postCubit = PostDetailsCubit.of(context);
  final getDirectionCubit = GetDirectionCubit.of(context);
  final promoCodeCubit = PromoCodeCubit.of(context);
//  TextEditingController controller = TextEditingController();
  return showModalBottomSheet(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0.r),
        topRight: Radius.circular(16.0.r),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.all(20.0.w),
      child: SizedBox(
        height: 250.h,
        child: Column(
          children: [
            BlocListener<PromoCodeCubit, PromoCodeState>(
              listener: (context, state) {},
              child: BlocBuilder<PromoCodeCubit, PromoCodeState>(
                builder: (BuildContext context, state) {
                  return state is SendMsgLoaded
                      ? Column(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: SpinImage(
                                imageUrl: AppAssets.loadingimage,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              LocaleKeys.wait.tr(),
                              style: FontStyles.textStyle18,
                            ),
                          ],
                        )
                      : promoCodeCubit.promoCodeModel != null
                          ? Text(
                              promoCodeCubit.promoCodeModel!.message,
                              style: FontStyles.textStyle18,
                            )
                          : const Text('');
                },
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            BlocListener<PromoCodeCubit, PromoCodeState>(
              listener: (BuildContext context, state) {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: customTextField(
                        color: const Color(0xffD5DDE0),
                        hintText: LocaleKeys.promoCode.tr(),
                        isPassword: false,
                        type: TextInputType.text,
                        controller: promoCodeCubit.couponController),
                  ),
                  SizedBox(
                      width: 80.w,
                      height: 48.h,
                      child: CustomButton(
                        text: LocaleKeys.active.tr(),
                        textColor: kWhite,
                        backgroundColor: kDeepBlue,
                        onPressed: () => promoCodeCubit.promoCode(),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(child: BlocBuilder<PostDetailsCubit, PostDetailsState>(
              builder: (context, state) {
                return state is PostDetailsLoading
                    ? //CircularProgressIndicator()
                    Column(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: SpinImage(
                              imageUrl: AppAssets.loadingimage,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            LocaleKeys.wait.tr(),
                            style: FontStyles.textStyle18,
                          ),
                        ],
                      )
                    : CustomButton(
                        backgroundColor: kDeepBlue,
                        text: LocaleKeys.bookRide.tr(),
                        textColor: kWhite,
                        onPressed: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar(
                              LocaleKeys.noInternetConnectivity.tr(),
                            );
                          }
                          postCubit.postData(
                            startRide: 'Current Location',
                            currentLat: currentPosition.latitude,
                            currentLong: currentPosition.longitude,
                            cost: 0,
                            coupunId: promoCodeCubit.promoCodeModel?.coupon.id,
                          );
                          getDirectionCubit.changetravelstate("وافق السائق");
                          getDirectionCubit.driverArrived();

                          //getDirectionCubit.drivercancelled(context);
                          // MagicRouter.navigateTo(const SearchingCarView())
                          // log( getDirectionCubit.directionDetails!.durationText!,);
                          //  log( getDirectionCubit.directionDetails!.endAddress!,);
                        },
                      );
              },
            ))
          ],
        ),
      ),
    ),
  );
}

/*
Future<dynamic> buildRateModalBottomSheet(BuildContext context) {
  // final cubit = GetDirectionCubit.of(context);

  final cubitDriver = RateCubit.of(context);
  final postCubit = PostDetailsCubit.of(context);
  dynamic rate;
  return showModalBottomSheet(
    backgroundColor: Colors.white70,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0.r),
        topRight: Radius.circular(16.0.r),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BlocProvider(
        create: (context) => GetDriverCubit()
          ..getDriverDetails(PostDetailsCubit.of(context).bookRideModel!.id),
        child: BlocBuilder<GetDriverCubit, GetDriverState>(
          builder: (context, state) {
            final getDriver = GetDriverCubit.of(context);
            return state is GetDriverLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 440.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -50.h,
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: kWhite,
                            // ignore: unnecessary_null_comparison
                            child: getDriver.getDriverData!.photo == null
                                ? Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        Image.asset('assets/images/user.png'))
                                : Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            getDriver.getDriverData!.photo),
                                      ),
                                    )),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Positioned(
                          top: 50.h,
                          left: 10,
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      getDriver.getDriverData!.name,
                                      style: FontStyles.textStyle18,
                                    ),
                                    SizedBox(
                                      width: 100.w,
                                    ),
                                    Container(
                                      height: 30.h,
                                      width: 70.w,
                                      decoration: BoxDecoration(
                                          color: const Color(0xffD5DDE0),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      child: Center(
                                          child: Text(
                                        getDriver.getDriverData!.carBoard
                                            .toString(),
                                        style: FontStyles.textStyle15
                                            .copyWith(color: kBlack),
                                        textAlign: TextAlign.center,
                                      )),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      getDriver.getDriverData!.carType,
                                      style: FontStyles.textStyle15.copyWith(
                                          color: kBlack,
                                          fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                RatingBar.builder(
                                  itemSize: 22.r,
                                  initialRating: 0,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  glowColor: Colors.white,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: .5),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    rate = rating;
                                  },
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                SizedBox(
                                  height: 120.h,
                                  width: 300.w,
                                  child: CustomMessageTextField(
                                      hint: LocaleKeys.yourMessageHere.tr(),
                                      maxLines: 4,
                                      controller: cubitDriver.msgController),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                BlocBuilder<RateCubit, RateState>(
                                  builder: (context, state) {
                                    return Center(
                                      child: CustomButton(
                                          text: LocaleKeys.rate.tr(),
                                          textColor: kWhite,
                                          backgroundColor: kDeepBlue,
                                          onPressed: () => cubitDriver.rating(
                                              rate,
                                              postCubit.bookRideModel!.id)),
                                    );
                                  },
                                ),
                                // Center(
                                //   child: CustomButton(
                                //     text: LocaleKeys.rate.tr(),
                                //     textColor: kWhite,
                                //     backgroundColor: kDeepBlue,
                                //     onPressed: () {
                                //       cubitDriver.rating(1, postCubit.bookRideModel!.id);
                                //     },
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
          },
        ),
      ),
    ),
  );
}
*/
Future<dynamic> buildContactDriverBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0.r),
        topRight: Radius.circular(16.0.r),
      ),
    ),
    context: context,
    builder: (context) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 280.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -50.h,
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: kWhite,
                child: CircleAvatar(
                  radius: 35.r,
                  child: Image.asset(AppAssets.user),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Positioned(
              top: 50.h,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'M.Reda',
                          style: FontStyles.textStyle18,
                        ),
                        SizedBox(
                          width: 200.w,
                        ),
                        Container(
                          height: 30.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                              color: const Color(0xffD5DDE0),
                              borderRadius: BorderRadius.circular(16)),
                          child: Center(
                              child: Text(
                            'HS785K',
                            style:
                                FontStyles.textStyle15.copyWith(color: kBlack),
                            textAlign: TextAlign.center,
                          )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      children: [
                        Text(
                          'Toyota Corolla 2018 - Gray',
                          style: FontStyles.textStyle15.copyWith(
                              color: kBlack, fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
//                    CustomRatingBar(),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 140.w,
                          child: CustomButton(
                            text: LocaleKeys.contactDriver.tr(),
                            textColor: kWhite,
                            backgroundColor: kDeepBlue,
                            onPressed: () => launch('tel:${01017397522}'),
                          ),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        SizedBox(
                          width: 140.w,
                          child: CustomButton(
                            text: LocaleKeys.cancel.tr(),
                            textColor: kWhite,
                            backgroundColor: const Color(0xff980011),
                            onPressed: () => MagicRouter.navigateTo(
                                const CancelingReasonsView()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> showCancleAlertDialog({
  required BuildContext context,
}) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
              content: SizedBox(
            height: 160.h,
            child: Column(
              children: [
                Image.asset(AppAssets.bookCar),
                SizedBox(
                  height: 10.h,
                ),
                Text(LocaleKeys.driverCancelledRide.tr(),
                    style: const TextStyle(color: kDeepBlue)),
                SizedBox(
                  height: 5.h,
                ),
                SizedBox(
                  width: 130.w,
                  height: 45.h,
                  child: CustomButton(
                    text: LocaleKeys.backToHome.tr(),
                    textColor: kWhite,
                    backgroundColor: kDeepBlue,
                    onPressed: () {
                      MagicRouter.navigateAndPopAll(const AfterSplashView());
                      listenDriverCanceled.remove();
                      listenNotification.onChildAdded.drain();
                      listenNotification.remove();
                    },
                  ),
                )
              ],
            ),
          )));
}

Future<dynamic> buildRateModalBottomSheet(BuildContext context) {
  final cubitDriver = RateCubit.of(context);
  final postCubit = PostDetailsCubit.of(context);
  double rate = 0;

  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
          bottomLeft: Radius.circular(30.r),
        ),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BlocProvider(
        create: (context) => GetDriverCubit()
          ..getDriverDetails(PostDetailsCubit.of(context).bookRideModel!.id),
        child: BlocBuilder<GetDriverCubit, GetDriverState>(
          builder: (context, state) {
            final getDriver = GetDriverCubit.of(context);
            return state is GetDriverLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    height: 440.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -50.h,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundColor: Colors.white,
                              child: getDriver.getDriverData?.photo == null
                                  ? Image.asset('assets/images/user.png',
                                      width: 80.w, height: 80.w)
                                  : Container(
                                      width: 80.w,
                                      height: 80.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              getDriver.getDriverData!.photo),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 60.h, 16.w, 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getDriver.getDriverData?.name ?? '',
                                    style: FontStyles.textStyle18,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffD5DDE0),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      getDriver.getDriverData?.carBoard
                                              .toString() ??
                                          '',
                                      style: FontStyles.textStyle15
                                          .copyWith(color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                getDriver.getDriverData?.carType ?? '',
                                style: FontStyles.textStyle15.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Center(
                                child: RatingBar.builder(
                                  itemSize: 22.r,
                                  initialRating: 0,
                                  minRating: 0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 2.w),
                                  itemBuilder: (context, _) =>
                                      Icon(Icons.star, color: Colors.amber),
                                  onRatingUpdate: (rating) {
                                    rate = rating;
                                  },
                                ),
                              ),
                              SizedBox(height: 15.h),
                              CustomMessageTextField(
                                hint: LocaleKeys.yourMessageHere.tr(),
                                maxLines: 4,
                                controller: cubitDriver.msgController,
                              ),
                              SizedBox(height: 20.h),
                              BlocBuilder<RateCubit, RateState>(
                                builder: (context, state) {
                                  return Center(
                                    child: CustomButton(
                                      text: LocaleKeys.rate.tr(),
                                      textColor: Colors.white,
                                      backgroundColor: kDeepBlue,
                                      onPressed: () => cubitDriver.rating(
                                          rate, postCubit.bookRideModel!.id),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    ),
  );
}
