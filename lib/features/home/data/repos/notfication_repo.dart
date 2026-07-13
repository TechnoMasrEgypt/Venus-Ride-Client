import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:taxi/core/utils/end_points.dart';
import 'package:taxi/core/utils/print_helper.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/cache_helper.dart';
import '../../../../core/utils/dio_helper.dart';
import '../../../../core/utils/error_model.dart';
import '../models/notfication_model.dart';

class NotficationRepo {
  Future<Either<String, NotficationchModel>> notficationRepo() async {
    final response = await DioHelper.get(EndPoints.createNewToken, headers: {
      'lang': AppStorage.getLang,
      'token': CacheHelper.getData(key: 'token'),
      'app': 'client',
      'userid': CacheHelper.getData(key: 'userId'),
    });
    PrintHalper.printSuccess(
      AppStorage.getLang,
    );
    PrintHalper.printSuccess(
      CacheHelper.getData(key: 'token'),
    );
    PrintHalper.printSuccess(
      "${CacheHelper.getData(key: 'userId')}",
    );
    try {
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        log("Success notficationRepo");
        print(response);
        return Right(NotficationchModel.fromJson(response.data));
      } else {
        PrintHalper.printError('error');
       return Left(ErrorModel.fromJson(response.data).message.toString());

      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
