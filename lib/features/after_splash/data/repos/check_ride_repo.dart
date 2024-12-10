import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:taxi/core/utils/app_storage.dart';
import 'package:taxi/core/utils/cache_helper.dart';
import 'package:taxi/core/utils/dio_helper.dart';
import 'package:taxi/core/utils/end_points.dart';
import 'package:taxi/core/utils/error_model.dart';
import 'package:taxi/features/home/data/models/book_ride_model.dart';

class CheckRide {
  Future<Either<String, BookRideModel>> postDetails({
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
    final response =
        await DioHelper.get(EndPoints.checkInRide, body: {}, headers: {
      'client': CacheHelper.getData(key: 'userId'),
      'lang': AppStorage.getLang,
      'dlat': dLat,
      'dlng': dLong,
    });

    try {
      if (response.statusCode == 200) {
        print("Success PostDetailsRepo");
        print('////////////////');
        print(response);
        print('////////////////');
        return Right(BookRideModel.fromJson(jsonDecode(response.toString())));
      } else {
        print(response);
        return Left(ErrorModel.fromJson(jsonDecode(response.toString()))
            .message
            .toString());
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
