import 'dart:convert';
import 'package:http/http.dart' as http;
import 'blog_post.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:3000'; //  API base URL
  static const String baseUrl = 'http://10.0.2.2:3000'; // localhost API base URL for Android

  // Fetch all blog posts from the API
  static Future<List<BlogPost>> fetchBlogPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => BlogPost.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load blog posts');
    }
  }

  // Update likes for a specific post
  static Future<void> updatePostLikes(int postId) async {
    final response = await http.put(Uri.parse('$baseUrl/posts/$postId/like'));

    if (response.statusCode != 200) {
      throw Exception('Failed to update post likes');
    }
  }
}
