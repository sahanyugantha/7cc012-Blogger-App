class PostItem {
  int? id;
  final String title;
  final String description;
  final String imageURL;
  final int userId;
  final String author;
  final DateTime createTime;
  int likes;
  Set<int>? likedBy;

  PostItem({
    this.id,
    required this.title,
    required this.description,
    required this.imageURL,
    required this.userId,
    required this.author,
    required this.createTime,
    this.likes = 0,
    this.likedBy,
  });

  @override
  String toString() {
    return 'PostItem {id: $id, title: $title, description: $description, userID: $userId, author: $author, imageURL: $imageURL, likes: $likes, likedBy: $likedBy, createTime: $createTime}';
  }

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

  // Method to toggle like status for a user
  void toggleLike(int userId) {
    if (likedBy!.contains(userId)) {
      // If the user already liked the post, unlike it
      likedBy!.remove(userId);
      likes = (likes! > 0) ? likes! - 1 : 0; // Ensure likes count doesn't go negative
    } else {
      // If the user hasn't liked the post yet, like it
      likedBy!.add(userId);
      likes = (likes! >= 0) ? likes! + 1 : 1; // Increment likes count
    }
  }

  // Method to remove all likes done by a user to posts
  void unlikeAll(int userId) {
    if (likedBy!.contains(userId)) {
      // If the user has liked the post, remove the like
      likedBy!.remove(userId);
      likes = (likes! > 0) ? likes! - 1 : 0; // Decrement likes count
    }
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
