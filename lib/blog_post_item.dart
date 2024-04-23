class PostItem {
  int? id;
  final String title;
  final String description;
  final String imageURL;
  final int? userId;
  final String author;
  final DateTime createTime;
  int? likes = 0;
  Set<int>? likedBy = {};

  PostItem({
    this.id,
    required this.title,
    required this.description,
    required this.imageURL,
    required this.userId,
    required this.author,
    required this.createTime,
    this.likes,
    this.likedBy,
  });

  factory PostItem.fromMap(Map<String, dynamic> map) {
    return PostItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imageURL: map['image_url'] ?? '',
      userId: map['user_id'],
      author: map['author'] ?? '',
      createTime: DateTime.parse(map['create_time']),
      likes: map['likes'] ?? 0,
      likedBy: map['liked_by'] != null ? Set<int>.from(map['liked_by']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageURL,
      'user_id': userId,
      'author': author,
      'create_time': createTime.toIso8601String(),
      'likes': likes,
      'liked_by': likedBy?.toList(),
    };
  }
}
