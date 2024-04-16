class UserData {
  final int id;
  final String username;
  final String email;
  final String? imageURL;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    this.imageURL,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      imageURL: json['image_url'],
    );
  }
}