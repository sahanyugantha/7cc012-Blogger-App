class BlogPost {
  final int id;
  final String title;
  final String description;
  final String? imageURL;
  final int? num;

  BlogPost({
    required this.id,
    required this.title,
    required this.description,
    this.imageURL,
    this.num,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageURL: json['imageURL'],
      num: json['num'],
    );
  }
}
