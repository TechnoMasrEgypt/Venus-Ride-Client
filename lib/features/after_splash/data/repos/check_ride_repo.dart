import 'dart:convert';
import 'dart:ffi';

import 'package:dartz/dartz.dart';
import 'package:taxi/core/utils/app_storage.dart';
import 'package:taxi/core/utils/cache_helper.dart';
import 'package:taxi/core/utils/dio_helper.dart';
import 'package:taxi/core/utils/end_points.dart';
import 'package:taxi/core/utils/error_model.dart';
import 'package:taxi/features/after_splash/data/models/check_drive_error.dart';
import 'package:taxi/features/after_splash/data/models/check_drive_model.dart';

class CheckRideRepo {
  static Future<Either<CheckDriveError, CheckDriveDetails>>
      checkInRide() async {
    final response =
        await DioHelper.get(EndPoints.checkInRide, body: {}, headers: {
      'user_id': CacheHelper.getData(key: 'userId'),
      'lang': AppStorage.getLang,
    });

    try {
      if (response.data["message"] == "waitng ride") {
        return Left(CheckDriveError.fromJson(jsonDecode(response.toString())));
      } else if (response.statusCode == 200 && response.data["id"] != null) {
        print("Success PostDetailsRepo");
        print("Success PostDetailsRepo");
        print('////////////////');
        print(response);
        print('////////////////');
        return Right(
            CheckDriveDetails.fromJson(jsonDecode(response.toString())));
      } else {
        print(response);
        return Left(CheckDriveError(
          message: ErrorModel.fromJson(jsonDecode(response.toString()))
              .message
              .toString(),
          rideId: null,
        ));
      }
    } catch (e) {
      return Left(CheckDriveError(
        message: e.toString(),
        rideId: null,
      ));
    }
  }
}
