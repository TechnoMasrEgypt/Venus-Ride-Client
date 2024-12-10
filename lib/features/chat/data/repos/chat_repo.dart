import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:taxi/features/chat/data/models/send_message_model.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/cache_helper.dart';
import '../../../../core/utils/dio_helper.dart';
import '../../../../core/utils/end_points.dart';
import '../../../../core/utils/error_model.dart';

class ChatRepo {
  Future<Either<String, SendMessageModel>> sendMessage(
      {required String msg, required int rideId}) async {
    final response = await DioHelper.post(EndPoints.sendMessage, body: {
      'message': msg,
    }, headers: {
      'userId': CacheHelper.getData(key: 'userId'),
      'type': 'client',
      'lang': AppStorage.getLang,
      'ride': rideId
    });
    try {
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        print("Success LoginRepo");
        print(response);
        return Right(
            SendMessageModel.fromJson(jsonDecode(response.toString())));
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
