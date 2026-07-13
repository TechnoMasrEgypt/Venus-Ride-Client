// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/dio_helper.dart';
import '../../../../core/utils/end_points.dart';
import '../../../../core/utils/error_model.dart';
import '../models/user_model.dart';

class RegisterRepo {
  Future<Either<String, UserModel>> register(
      {required String name,
      required String phone,
      required String password,
      required String conPassword}) async {
    String? devicetoken;
    try {
      devicetoken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('FCM token fetch failed: $e');
      devicetoken = null;
    }

    try {
      final response = await DioHelper.post(EndPoints.register, body: {
        'name': name,
        'phone': phone,
        'password': password,
        'password_confirmation': conPassword,
        'device_token': devicetoken,
      }, headers: {
        'Accept': 'application/json',
        'lang': AppStorage.getLang,
      });

      print('STATUS CODE: ${response.statusCode}');
      print('RAW RESPONSE DATA: ${response.data}');
      print('RESPONSE DATA TYPE: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return Right(UserModel.fromJson(response.data));
      } else {
        // print('PARSED ERROR: ${response.data}');
        return Left(ErrorModel.fromJson(response.data).message.toString());
      }
    } catch (e, stack) {
      print('EXCEPTION IN REGISTER: $e');
      print('STACK TRACE: $stack');
      return Left(e.toString());
    }
  }
}
