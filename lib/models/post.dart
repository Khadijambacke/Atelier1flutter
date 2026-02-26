class Post {
  final int id;
  final String title;
  final String body;
  final int userId;

  // Constructeur
  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'body': body, 'userId': userId};
  }

  Post copyWith({String? title, String? body}) {
    return Post(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId,
    );
  }

  @override
  String toString() => 'Post(id: $id, title: $title)';
}
