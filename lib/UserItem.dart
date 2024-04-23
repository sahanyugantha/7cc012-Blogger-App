class UserItem {
  int? id;
  final String username;
  final String email;
  final String password;
  final DateTime createTime;
  final String imageURL;

  UserItem({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createTime,
    required this.imageURL,
  });

  factory UserItem.fromMap(Map<String, dynamic> map) {
    return UserItem(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createTime: DateTime.parse(map['create_time']),
      imageURL: map['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'create_time': createTime.toIso8601String(),
      'image_url': imageURL,
    };
  }

  // Convert UserItem to a JSON-compatible Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'create_time': createTime.toIso8601String(),
      'image_url': imageURL,
    };
  }

  // Factory method to create a UserItem from a JSON map
  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      createTime: DateTime.parse(json['create_time'] ?? ''),
      imageURL: json['image_url'] ?? '',
    );
  }
}
