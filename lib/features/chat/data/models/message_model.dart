// class MessageModel {
//   final String message;
//   final String id;

//   MessageModel({
//     required this.message,
//     required this.id,
//   });

//   factory MessageModel.fromJson(QueryDocumentSnapshot snapshot) {
//     return MessageModel(
//       message: snapshot['message'],
//       id: snapshot['id'].toString(), // Convert id to String
//     );
//   }
// }
class MessageModel {
  final String id;
  final String message;
  final String userId;
  final String createdAt;

  MessageModel(
      {required this.id,
      required this.message,
      required this.userId,
      required this.createdAt});
}
