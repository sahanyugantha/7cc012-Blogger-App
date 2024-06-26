import 'dart:convert';
import 'package:blogger/online/userdata.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'blog_post.dart';
import 'dart:async';
import 'dart:io';

class ApiService {
  // static const String baseUrl = 'http://localhost:3000'; //  API base URL
  //static const String baseUrl = 'http://10.0.2.2:3000'; // localhost API base URL for Android
  //static const String baseUrl = 'http://192.168.0.188:3000'; // localhost API base URL of my network
  static const String baseUrl = 'http://172.25.69.126:3000'; // localhost API base URL of  uni eduroam

  /// FOR emojis
  /// ALTER DATABASE blogdb CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
  /// ALTER TABLE post CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  /// ALTER TABLE user CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

  // Fetch all blog posts from the API
  static Future<List<BlogPost>> fetchBlogPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        List<BlogPost> posts = jsonData.map((data) => BlogPost.fromJson(data)).toList();

        // Initialize likedBy lists based on user's like status
        UserData? userData = await getUserData();
        int? userId = userData?.id;

        for (var post in posts) {
          post.likedBy = post.likedBy ?? {};
          if (userId != null && post.likedBy!.contains(userId)) {
            print("YEAH-----------POST ${post.id} ---------------> $userId");
            post.likedBy!.add(userId);
          }
        }
        return posts;
      } else {
        throw Exception('Failed to load blog posts');
      }
    } catch (e) {
      throw Exception('Failed to fetch blog posts: $e');
    }
  }

  // Fetch all logged in user's blog posts from the API
  static Future<List<BlogPost>> fetchUserPosts(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/user/$id'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        List<BlogPost> posts = jsonData.map((data) => BlogPost.fromJson(data)).toList();

        // Initialize likedBy lists based on user's like status
        UserData? userData = await getUserData();
        int? userId = userData?.id;

        for (var post in posts) {
          post.likedBy = post.likedBy ?? {};
          if (userId != null && post.likedBy!.contains(userId)) {
            post.likedBy!.add(userId);
          }
        }
        return posts;
      } else {
        throw Exception('Failed to load blog posts');
      }
    } catch (e) {
      throw Exception('Failed to fetch blog posts: $e');
    }
  }

  // Update likes for a specific post
  // static Future<void> updatePostLikes(int postId) async {
  //   final response = await http.put(Uri.parse('$baseUrl/posts/$postId/like'));
  //
  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to update post likes');
  //   }
  // }

  static Future<void> updatePostLikes(int postId, int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/$postId/like'),
        headers: {
          'Content-Type': 'application/json', // Set content type to JSON
        },
        body: jsonEncode({
          'userId': userId.toString(), // Include userId in the request body
        }),
      );

      if (response.statusCode == 200) {
        print('Post liked successfully');
      } else {
        throw Exception('Failed to update post likes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating post likes: $e');
      throw Exception('Failed to update post likes: $e');
    }
  }

  static Future<void> removePostLike(int postId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId/like/$userId'),
      );

      if (response.statusCode == 200) {
        print('Post like removed successfully');
      } else {
        throw Exception('Failed to remove post like: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error removing post like: $e');
      throw Exception('Failed to remove post like: $e');
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

  static Future<bool> performLogin(String email, String password) async {
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
        return true;
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

  static performLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }


  static Future<void> registerUser(String username, String email, String password, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'imageUrl': imageUrl,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Registration successful
        print('User registered successfully');
      } else {
        // Registration failed

        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred during registration
      print('Error during registration: $e');
      throw Exception('Error during registration');
    }
  }

  static Future<void> changeUsername(int? id, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/change-username/$id'),
        body: json.encode({
          'username': username,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // update successful
        print('Username changed successfully');
      } else {
        // update failed
        throw Exception('Failed to change username: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred during updating
      print('Error during updating: $e');
      throw Exception('Error during updating');
    }
  }

  static Future<void> deleteUser(int? id, String email, String password) async {
    try {

      if(await performLogin(email, password)) {
        final response = await http.delete(
          Uri.parse('$baseUrl/users/$id'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          // user deleted successful
          print('User deleted successfully');
        } else {
          // Password change failed
          throw Exception('Failed to delete user: ${response.statusCode}');
        }
      } else {
        throw Exception('Incorrect password');
      }
    } catch (e) {
      // Exception occurred during updating
      throw Exception('Error during deleting user $e');
    }
  }

  static Future<void> changePassword(int? id, String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/change-password/$id'),
        body: json.encode({
          'oldpassword': oldPassword,
          'newpassword': newPassword,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Password change successful
        print('Password changed successfully');
      } else {
        // Password change failed
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred during updating
      print('Error during updating: $e');
      throw Exception('Error during updating');
    }
  }

  static Future<UserData?> getUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final Map<String, dynamic> userDataMap = jsonDecode(userDataString);
        return UserData.fromJson(userDataMap); // Convert JSON map to UserData object
      } else {
        return null; // Return null if no user data is found
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null; // Return null in case of an error
    }
  }



/// *************<<<<<< Posts Api Calls >>>>>>>>******************* ///
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

      if (response.statusCode == 200) {
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


  static Future<void> updatePost(int id, String title, String description, File? imageFile, int userId) async {
    try {
      var uri = Uri.parse('$baseUrl/posts/$id');
      var request = http.MultipartRequest('PUT', uri);
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['userId'] = userId.toString();

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

  static Future<void> deletePost(int id) async {
    try {
      var uri = Uri.parse('$baseUrl/posts/$id');
      var request = http.Request('DELETE', uri);

      var response = await request.send();

      if (response.statusCode == 200) {
        // Post successfully added
        print('Post deleted successfully');
      } else {
        int code = response.statusCode;
        print('Failed to remove post ---  response = $code');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }

}
