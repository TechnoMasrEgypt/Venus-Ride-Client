// To parse this JSON data, do
//
//     final notficationchModel = notficationchModelFromJson(jsonString);

import 'dart:convert';

NotficationchModel cancelSearchModelFromJson(String str) =>
    NotficationchModel.fromJson(json.decode(str));

String cancelSearchModelToJson(NotficationchModel data) =>
    json.encode(data.toJson());

class NotficationchModel {
  NotficationchModel({
    required this.status,
    required this.message,
    this.data,
  });

  String status;
  String message;
  dynamic data;

  factory NotficationchModel.fromJson(Map<String, dynamic> json) =>
      NotficationchModel(
        status: json["status"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}
