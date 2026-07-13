class SettingsResponse {
  final String status;
  final String message;
  final List<SettingItem> data;

  SettingsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => SettingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SettingItem {
  final int id;
  final String key;
  final String value;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SettingItem({
    required this.id,
    required this.key,
    required this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory SettingItem.fromJson(Map<String, dynamic> json) {
    return SettingItem(
      id: json['id'] as int,
      key: json['key'] as String,
      value: json['value'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}