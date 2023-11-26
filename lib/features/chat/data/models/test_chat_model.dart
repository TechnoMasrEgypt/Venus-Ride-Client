class ChatMessage {
  final String status;
  final String message;
  final List<ChatData> data;

  ChatMessage(
      {required this.status, required this.message, required this.data});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<ChatData> chatDataList =
        dataList.map((data) => ChatData.fromJson(data)).toList();

    return ChatMessage(
      status: json['status'],
      message: json['message'],
      data: chatDataList,
    );
  }
}

class ChatData {
  final String message;
  final String createdAt;
  final List<ChatReply> replies;

  ChatData(
      {required this.message, required this.createdAt, required this.replies});

  factory ChatData.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List;
    List<ChatReply> replies =
        repliesList.map((reply) => ChatReply.fromJson(reply)).toList();

    return ChatData(
      message: json['message'],
      createdAt: json['created_at'],
      replies: replies,
    );
  }
}

class ChatReply {
  final int id;
  final User user;
  final String replies;
  final String createdAt;

  ChatReply(
      {required this.id,
      required this.user,
      required this.replies,
      required this.createdAt});

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    return ChatReply(
      id: json['id'],
      user: User.fromJson(json['user']),
      replies: json['replies'],
      createdAt: json['created_at'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String language;
  final String phone;
  final String photo;

  User(
      {required this.id,
      required this.name,
      required this.language,
      required this.phone,
      required this.photo});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      phone: json['phone'],
      photo: json['photo'],
    );
  }
}
