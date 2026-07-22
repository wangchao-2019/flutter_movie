/// 留言数据模型。
class MessageModel {
  final int id;
  final String name;
  final String content;
  final String? contact;
  final DateTime createdAt;
  final String userEmail;

  const MessageModel({
    required this.id,
    required this.name,
    required this.content,
    this.contact,
    required this.createdAt,
    required this.userEmail,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      content: json['content'] as String,
      contact: json['contact'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userEmail: json['userEmail'] as String,
    );
  }
}
