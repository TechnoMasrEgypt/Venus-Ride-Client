import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/core/utils/cache_helper.dart';
import 'package:taxi/core/utils/magic_router.dart';
import 'package:taxi/features/after_splash/data/repos/check_ride_repo.dart';
import 'package:taxi/features/home/presentations/views/searching_car_view.dart';
import 'package:taxi/features/home/presentations/views_models/post_details_cubit/post_details_cubit.dart';
import 'package:taxi/features/tracker_map/presentations/views/tracker_map.dart';

import '../../../../../core/widgets/custom_snackbar.dart';

part 'check_ride_state.dart';

class CheckRideCubit extends Cubit<CheckRideState> {
  CheckRideCubit() : super(CheckRideInitial());

  Future<void> checkRide() async {
    emit(StartCheckRide());

    final userId = CacheHelper.getData(key: 'userId');
    if (userId == null) {
      // No logged-in user — still need a terminal state, otherwise
      // anything waiting on this cubit (e.g. splash navigation) hangs
      // forever in StartCheckRide.
      emit(ErrorCheckRide(message: 'not_logged_in'));
      return;
    }

    final res = await CheckRideRepo.checkInRide();
    res.fold(
      (err) {
        if (err.message == "waitng ride") {
          MagicRouter.navigateAndPopAll(const SearchingCarView());
          PostDetailsCubit.of(MagicRouter.currentContext)
              .setRideData(id: err.rideId!);
          emit(CheckRideSuccess(message: err.message));
          return;
        }

        // Not having an ongoing ride is the normal case, not a failure —
        // don't alarm the user with an error snackbar for it.
        if (err.message != "No ongoing ride found for client") {
          showSnackBar(err.message);
        }

        emit(ErrorCheckRide(message: err.message));
      },
      (res) {
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

        showSnackBar(res.message!);
        emit(CheckRideSuccess(message: res.message!));
      },
    );
  }

  static CheckRideCubit of(context) => BlocProvider.of(context);
}