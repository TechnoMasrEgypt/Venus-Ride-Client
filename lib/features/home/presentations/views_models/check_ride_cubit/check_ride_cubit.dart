import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/core/utils/cache_helper.dart';
import 'package:taxi/core/utils/magic_router.dart';
import 'package:taxi/features/after_splash/data/repos/check_ride_repo.dart';
import 'package:taxi/features/home/presentations/views/searching_car_view.dart';
import 'package:taxi/features/home/presentations/views_models/post_details_cubit/post_details_cubit.dart';
import 'package:taxi/features/tracker_map/presentations/views/tracker_map.dart';

part 'check_ride_state.dart';

class CheckRideCubit extends Cubit<CheckRideState> {
  CheckRideCubit() : super(CheckRideInitial());

  Future checkRide() async {
    emit(StartCheckRide());
    if (CacheHelper.getData(key: 'userId') == null) {
      print("444444444");
      return;
    }
    final res = await CheckRideRepo.checkInRide();
    res.fold(
      (err) {
        if (err.message == "waitng ride") {
          MagicRouter.navigateAndPopAll(const SearchingCarView());
          PostDetailsCubit.of(MagicRouter.currentContext)
              .setRideData(id: err.rideId!);
        }
        //

        emit(ErrorCheckRide());
      },
      (res) async {
        PostDetailsCubit.of(MagicRouter.currentContext)
            .setRideData(id: res.ride);
        MagicRouter.navigateAndPopAll(TrackerMapView(
          board: res.board,
          driver: res.driver,
          phone: res.phone,
          photo: res.photo,
          rate: res.rate,
          type: res.type,
          iDdriver: res.driverId,
          ride: res.ride,
          status: res.status,
        ));

        emit(CheckRideSuccess());
      },
    );
  }

  static CheckRideCubit of(context) => BlocProvider.of(context);
}
