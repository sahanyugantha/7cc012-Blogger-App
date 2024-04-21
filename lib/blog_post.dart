class BlogPost {
  final int id;
  final String title;
  final String description;
  final String? imageURL;
  int likes;
  Set<int>? likedBy;
  final String author;
  final DateTime createTime;

  BlogPost({
    required this.id,
    required this.title,
    required this.description,
    this.imageURL,
    this.likes = 0,
    this.likedBy,
    required this.author,
    required this.createTime,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? 'NA',
      imageURL: json['image'],
      likes: json['likes'] ?? 0,
      likedBy: json['likedBy'] != null ? Set<int>.from(json['likedBy']) : null,
      createTime:  DateTime.parse(json['create_time']),
    );
  }

  @override
  String toString() {
    return 'BlogPost{id: $id, title: $title, description: $description, author: $author, imageURL: $imageURL, likes: $likes, likedBy: $likedBy, createTime: $createTime}';
  }
}
