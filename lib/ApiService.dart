import 'dart:convert';
import 'package:blogger/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'blog_post.dart';
import 'dart:async';
import 'dart:io';

class ApiService {
  // static const String baseUrl = 'http://localhost:3000'; //  API base URL
  //static const String baseUrl = 'http://10.0.2.2:3000'; // localhost API base URL for Android
  static const String baseUrl = 'http://192.168.0.188:3000'; // localhost API base URL of my network

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

  static Future<void> saveUserData(UserData? userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print('USER DATA ********************** $userData');
    try {
      if (userData != null) {
        // Convert UserData to JSON string and save to SharedPreferences
        await prefs.setString('userData', jsonEncode(userData.toJson()));
      } else {
        // If userData is null, clear the saved data
        await prefs.remove('userData');
      }
    } catch (e) {
      print('ERROR USER DATA ********************** $e');
    }
  }

  static performLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Successful login
        final userData = json.decode(response.body);
        UserData userDataN = UserData.fromJson(userData);

    // Save user data to SharedPreferences
        await saveUserData(userDataN);
        //return UserData.fromJson(userData);
      } else {
        // Failed to login
        throw Exception('Failed to login');
      }
    } catch (e) {
      // Exception occurred during login
      print('Error during login: $e');
      throw Exception('Error during login');
    }
  }


  static getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    return userDataString != null ? jsonDecode(userDataString) : null;
  }

  static performLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }


/**
 * Posts Api Calls
 */
  static Future<void> addPost(String title, String description, File? imageFile, int id) async {
    try {
      var uri = Uri.parse('$baseUrl/posts');
      var request = http.MultipartRequest('POST', uri);
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['userId'] = id.toString();

      if (imageFile != null) {
        var imageStream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'image',
          imageStream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        // Post successfully added
        print('Post added successfully');
      } else {
        // Handle error
        int code = response.statusCode;
        print('Failed to add post ---  response = $code');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }


}
