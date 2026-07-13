import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/features/tracker_map/presentations/views/tracker_map.dart';
import '../../../../../core/utils/app_storage.dart';
import '../../../../../core/utils/magic_router.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../global_variables.dart';
import '../../../data/models/direction_details_model.dart';
import '../../../../../translations/locale_keys.g.dart';
import '../../../data/models/book_ride_model.dart';
import '../../../data/models/piceandtimesettingmodel.dart';
import '../../../data/repos/post_details_repo.dart';
import '../../views/searching_car_view.dart';
part 'post_details_state.dart';

class PostDetailsCubit extends Cubit<PostDetailsState> {
  PostDetailsCubit() : super(PostDetailsInitial());

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  List<SettingItem> settings = [];
  Future<bool> getSettings() async {
    final result = await postDetailsRepo.getSettings();

    return result.fold(
      (err) {
        showSnackBar(err);
        return false;
      },
      (res) {
        settings = res.data;
        return true;
      },
    );
  }

  double estimateFares(DirectionDetails details) {
    const double baseFare = 1.0;
    const double freeKmLimit = 2.0;
    const double freeMinLimit = 4.0;
    final double pricePerKilo = double.tryParse(
          settings
              .firstWhere(
                (s) => s.key == 'PricePerKilo',
                orElse: () => SettingItem(
                  id: 0,
                  key: 'PricePerKilo',
                  value: '0.5',
                ),
              )
              .value,
        ) ??
        0.5;

    final double tariff_price = double.tryParse(
          settings
              .firstWhere((s) => s.key == 'tariff_price',
                  orElse: () =>
                      SettingItem(id: 0, key: 'tariff_price', value: '0.10'))
              .value,
        ) ??
        0.10;

    final double totalKm = (details.distanceValue ?? 0) / 1000.0;
    final double totalMin = (details.durationValue ?? 0) / 60.0;

    double extraFare = 0.0;

    if (totalKm > freeKmLimit) {
      final double extraKm = totalKm - freeKmLimit;
      extraFare += extraKm * pricePerKilo;
    }

    if (totalMin > freeMinLimit) {
      final double extraMin = totalMin - freeMinLimit;
      extraFare += extraMin * tariff_price;
    }

    return roundDouble(baseFare + extraFare, 2);
  }

  final postDetailsRepo = PostDetailsRepo();
  Data? bookRideModel;
  static PostDetailsCubit of(context) => BlocProvider.of(context);

  Future postData({
    String? startRide,
    String? endRide,
    double? currentLat,
    double? currentLong,
    double? dLat,
    double? dLong,
    double? cost,
    String? distance,
    String? time,
    int? coupunId,
  }) async {
    deleteFirebaseRecord();

    emit(PostDetailsLoading());
    final res = await postDetailsRepo.postDetails(
        startRide: startRide,
        endRide: endRide,
        currentLat: currentLat,
        currentLong: currentLong,
        dLat: dLat,
        dLong: dLong,
        cost: cost,
        distance: distance,
        time: time,
        coupunId: coupunId);
    res.fold(
      (err) {
        showSnackBar(AppStorage.getLang == 'en'
            ? err
            : 'Please check your data again, you have an error in the data');
        emit(PostDetailsError());
      },
      (res) async {
        print("start 1");

        /*   final widget =
            ModalRoute.of(MagicRouter.currentContext!)?.settings.;
        print("testtesttest" + widget!.toString());*/
        showSnackBar(res.message);
        // showSnackBar(LocaleKeys.tripBookedSuccessfully.tr());
        // showSnackBar(AppStorage.getLang == 'en'?'Trip Booked Successfully ':'تم حجز الرحله بنجاح');
        bookRideModel = res.data;
        rideIdCancel = bookRideModel!.id;
        log(bookRideModel!.id);
        emit(PostDetailsLoaded());
        //  if (!(widget is TrackerMapView))
        MagicRouter.navigateAndPopAll(const SearchingCarView());
      },
    );
  }

  void deleteFirebaseRecord() {
    // Remove all related records
    listenReceipt.remove().then((_) {}).catchError((error) {});

    listenNotification.remove().then((_) {}).catchError((error) {});

    listenDriverArrived.remove().then((_) {}).catchError((error) {});

    listenDriverCanceled.remove().then((_) {}).catchError((error) {});
  }

  void setRideData({required int id}) {
    emit(PostDetailsLoading());

    bookRideModel = Data(
        id: id, date: DateTime.now(), time: "", startRide: "", endRide: "");
    emit(PostDetailsLoaded());
  }
}
