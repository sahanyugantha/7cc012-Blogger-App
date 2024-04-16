class BlogPost {
  final int id;
  final String title;
  final String description;
  final String? imageURL;
  int? likes;

  BlogPost({
    required this.id,
    required this.title,
    required this.description,
    this.imageURL,
    this.likes = 0,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageURL: json['image'],
      likes: json['likes'] ?? 0,
    );
  }
}
