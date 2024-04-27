import 'dart:convert';
import 'dart:io';
import 'package:blogger/UserItem.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'BlogDB.dart';
import '../blog_post_item.dart';

class DatabaseHelper {
  static Database? _database;

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // If _database is null, initialize it
    _database = await initDatabase();
    return _database!;
  }

  // Get the full path for the database
  Future<String> get fullPath async {
    const dbname = 'blog.db';
    final dbpath = await getDatabasesPath();
    return join(dbpath, dbname);
  }

  // Initialize the database
  Future<Database> initDatabase() async {
    String path = await fullPath;
    try {
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await BlogDB().createPostTable(db);
          await BlogDB().createUserTable(db);
          await BlogDB().createPostLikesTable(db);
          await BlogDB().createPostDetailsView(db);
        },
        singleInstance: true,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow; // Rethrow the error for higher-level handling
    }
  }

  // Retrieve all blog posts from the database

  Future<List<PostItem>> getBlogPosts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> postMaps = await db.query('post_details');
      final List<Map<String, dynamic>> postsWithLikesResult = await postsWithLikes();

      return List.generate(postMaps.length, (index) {
        final post = PostItem(
          id: postMaps[index]['id'],
          title: postMaps[index]['title'],
          description: postMaps[index]['description'],
          userId: postMaps[index]['user_id'],
          author: postMaps[index]['author'] ?? 'NA',
          imageURL: postMaps[index]['imageUrl'],
          likes: postMaps[index]['likes'] ?? 0,
          createTime: DateTime.parse(postMaps[index]['create_time']),
        );

        // Populate likedBy field using postsWithLikesResult
        final postId = post.id;
        Map<String, dynamic>? likedPost;
        for (final post in postsWithLikesResult) {
          if (post['id'] == postId) {
            likedPost = post;
            break;
          }
        }

        if (likedPost != null) {
          final likedByList = likedPost['likedBy'] as List<int>;
          post.likedBy = Set<int>.from(likedByList);
        }

        return post;
      });
    } catch (e) {
      print('Error fetching blog posts: $e');
      return []; // Return an empty list in case of an error
    }
  }

  // Fetch Post By Id
  Future<PostItem?> fetchPostById(int id) async {
    final database = await DatabaseHelper().database;
    final List<Map<String, dynamic>> posts = await database.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (posts.isNotEmpty) {
      return PostItem.fromMap(posts.first);
    }
    return null;
  }

  // Save a new post into the database
  Future<void> savePostData(PostItem postItem) async {
    try {
      final db = await database;
      await db.insert(
        'posts',
        {
          'title': postItem.title,
          'description': postItem.description,
          'imageUrl': postItem.imageURL,
          'create_time': postItem.createTime.toIso8601String(),
          'user_id': postItem.userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving post data: $e');
      rethrow; // Rethrow the error for higher-level handling
    }
  }

  // Update Post
  Future<int> updatePost(PostItem p) async {
    final database = await DatabaseHelper().database;
    return await database.update(
      'posts',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  // Delete Post
  Future<int> deletePost(int id) async {
    final database = await DatabaseHelper().database;
    return await database.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  ///USER///

  // Perform user login and save user data to SharedPreferences
  Future<UserItem?> performLogin(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (results.isNotEmpty) {
      UserItem userItem = UserItem.fromMap(results.first);
      saveUserDataSP(userItem); // Save user data to SharedPreferences
      return userItem;
    } else {
      return null; // Return null if login fails
    }
  }

  performLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  // Retrieve user data from the database
  Future<UserItem?> fetchUserData() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> userMaps = await db.query('user');

      if (userMaps.isNotEmpty) {
        return UserItem(
          id: userMaps[0]['id'],
          username: userMaps[0]['username'],
          email: userMaps[0]['email'],
          password: userMaps[0]['password'],
          createTime: DateTime.parse(userMaps[0]['create_time']),
          imageURL: userMaps[0]['image_url'],
        );
      } else {
        return null; // Return null if no user data is found
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return null; // Handle the error gracefully
    }
  }

  // Retrieve user data from the Shared Preferences
   Future<UserItem?> getUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final Map<String, dynamic> userDataMap = jsonDecode(userDataString);
        return UserItem.fromJson(userDataMap); // Convert JSON map to UserData object
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Error fetching user data: $e');
    }
  }

  // Save user data to SharedPreferences
  Future<void> saveUserDataSP(UserItem? userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      if (userData != null) {
        // Convert UserData to JSON string and save to SharedPreferences
        await prefs.setString('userData', jsonEncode(userData.toJson()));
      } else {
        // If userData is null, clear the saved data
        await prefs.remove('userData');
      }
    } catch (e) {
      print('Error saving user data to SharedPreferences: $e');
    }
  }

  // Create User
  Future<int> createUser(UserItem user) async {
    final database = await DatabaseHelper().database;
    return await database.insert('user', user.toMap());
  }

  // Fetch All Users
  Future<List<UserItem>> fetchAllUsers() async {
    final database = await DatabaseHelper().database;
    final users = await database.query('user');
    return users.map((user) => UserItem.fromMap(user)).toList();
  }

  // Fetch User By Id
  Future<UserItem?> fetchUserById(int id) async {
    final database = await DatabaseHelper().database;
    final List<Map<String, dynamic>> users = await database.query(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (users.isNotEmpty) {
      return UserItem.fromMap(users.first);
    }
    return null;
  }

  // Update User
  Future<int> updateUser(UserItem user) async {
    final database = await DatabaseHelper().database;
    return await database.update(
      'user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(UserItem userItem, String password) async {
    final database = await DatabaseHelper().database;
    if (password == userItem.password) {

      try {
        // remove all likes done by the user
        await database.delete(
          'post_likes', // Table name where likes are stored
          where: 'user_id = ?', // Where clause to find likes by user ID
          whereArgs: [userItem.id], // Value of the user ID
        );

        // Then delete the user
        await database.delete(
          'user', // Table name where users are stored
          where: 'id = ?', // Where clause to find the user by ID
          whereArgs: [userItem.id], // Value of the user ID
        );

      } catch (e) {
        throw Exception('Failed to delete user: $e');
      }
    }
  }

  Future<void> changeUsername(int? id, String newUsername) async {
    try {
      final database = await DatabaseHelper().database;
      await database.update(
        'user', // Table name
        {'username': newUsername}, // New username
        where: 'id = ?', // Where clause to find the user by ID
        whereArgs: [id], // Value of the ID
      );
    } catch (e) {
      throw Exception('Failed to change username: $e');
    }
  }

   Future<void> changePassword(UserItem userItem, String oldPassword, String newPassword) async {
    try {
      final database = await DatabaseHelper().database;
      if(oldPassword == userItem.password) {
        await database.update(
          'user', // Table name
          {'password': newPassword}, // New username
          where: 'id = ?', // Where clause to find the user by ID
          whereArgs: [userItem.id], // Value of the ID
        );
      } else {
        throw Exception('Incorrect password');
      }
    } catch (e) {
      // Exception occurred during updating
      print('Error during updating: $e');
      throw Exception('Error during updating');
    }
  }


  //// post_likes table////

  // Save a like for a post
  Future<void> savePostLike(int postId, int userId) async {
    try {
      final db = await database;
      await db.insert(
        'post_likes',
        {
          'post_id': postId,
          'user_id': userId,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print('Error saving post like: $e');
      rethrow; // Rethrow the error for higher-level handling
    }
  }

  // Remove a like for a post
  Future<void> removePostLike(int postId, int userId) async {
    try {
      final db = await database;
      await db.delete(
        'post_likes',
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );
    } catch (e) {
      print('Error removing post like: $e');
      rethrow; // Rethrow the error for higher-level handling
    }
  }

  // Check if a user has liked a post
  Future<bool> hasUserLikedPost(int postId, int userId) async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM post_likes WHERE post_id = ? AND user_id = ?',
        [postId, userId],
      ));
      return count! > 0;
    } catch (e) {
      print('Error checking if user has liked post: $e');
      return false; // Return false in case of an error
    }
  }



  // Fetch liked posts for a user
  Future<List<int>> fetchLikedPostsForUser(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> likes = await db.query(
        'post_likes',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return likes.map((like) => like['post_id'] as int).toList();
    } catch (e) {
      print('Error fetching liked posts for user: $e');
      return []; // Return an empty list in case of an error
    }
  }




/////VIEW/////
  // Fetch posts with their corresponding like counts
  // Future<List<Map<String, dynamic>>> postsWithLikes() async {
  //   try {
  //     final db = await database;
  //     final List<Map<String, dynamic>> posts = await db.rawQuery('''
  //       SELECT id, title, description, image, likes
  //       FROM post_details
  //     ''');
  //     return posts;
  //   } catch (e) {
  //     print('Error fetching posts with likes: $e');
  //     return []; // Return an empty list in case of an error
  //   }
  // }

  //uses the view
  // Fetch posts with their corresponding like counts
  // Fetch posts with their corresponding like counts
  Future<List<Map<String, dynamic>>> postsWithLikes() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> posts = await db.rawQuery('''
      SELECT id, title, description, image, likes
      FROM post_details
    ''');
      return posts;
    } catch (e) {
      print('Error fetching posts with likes: $e');
      return []; // Return an empty list in case of an error
    }
  }




  // Fetch posts for a specific user using the post_details view
  Future<List<PostItem>> fetchUserPosts(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> postMaps = await db.query(
        'post_details',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return List.generate(postMaps.length, (index) {
        return PostItem(
          id: postMaps[index]['id'],
          title: postMaps[index]['title'],
          description: postMaps[index]['description'],
          userId: postMaps[index]['user_id'],
          author: postMaps[index]['username'] ?? 'NA',
          imageURL: postMaps[index]['image'],
          likes: postMaps[index]['likes'] ?? 0,
          createTime: DateTime.parse(postMaps[index]['create_time']),
        );
      });
    } catch (e) {
      print('Error fetching user posts: $e');
      return []; // Return an empty list in case of an error
    }
  }

  /////////VIEW////////
  // Fetch posts from the post_details view
  Future<List<PostItem>> fetchPostsFromView() async {
    try {
      final db = await database;

      // Fetch posts
      final List<Map<String, dynamic>> postMaps = await db.query('post_details');

      // Fetch post likes
      final List<Map<String, dynamic>> postLikesMaps = await db.query('post_likes');

      // Create a map to store likes by post id
      final Map<int, Set<int>> likesByPostId = {};

      // Populate the map with likes
      for (final likeMap in postLikesMaps) {
        final postId = likeMap['post_id'];
        final userId = likeMap['user_id'];
        if (!likesByPostId.containsKey(postId)) {
          likesByPostId[postId] = {};
        }
        likesByPostId[postId]!.add(userId);
      }

      // Create PostItems with likedBy populated
      return postMaps.map((postMap) {
        final postId = postMap['id'];
        final likedBy = likesByPostId[postId] ?? {}; // Set likedBy to an empty set if there are no likes
        return PostItem(
          id: postMap['id'],
          title: postMap['title'],
          description: postMap['description'],
          userId: postMap['user_id'],
          author: postMap['username'] ?? 'NA',
          imageURL: postMap['image'],
          likes: postMap['likes'] ?? 0,
          createTime: DateTime.parse(postMap['create_time']),
          likedBy: likedBy,
        );
      }).toList();
    } catch (e) {
      print('Error fetching posts from view: $e');
      return []; // Return an empty list in case of an error
    }
  }




  // Retrieve user data from SharedPreferences
  Future<UserItem?> getUserDataSP() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final Map<String, dynamic> userDataMap = jsonDecode(userDataString);
        return UserItem.fromJson(userDataMap); // Convert JSON map to UserItem object
      } else {
        return null; // Return null if no user data is found
      }
    } catch (e) {
      print('Error fetching user data from SharedPreferences: $e');
      return null; // Return null in case of an error
    }
  }


  Future<String> getBasePath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  Future<String> saveImage(File imageFile, int userId, int postId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'assets', 'images', '$userId', '$postId'));

      // Check if the directory already exists
      if (!await imagesDir.exists()) {
        // If not, create it
        await imagesDir.create(recursive: true);
        print('Directory created: ${imagesDir.path}');
      }

      final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imagePath = path.join(imagesDir.path, imageName);

      // Print the image path before copying
      print('Copying image to: $imagePath');

      await imageFile.copy(imagePath);

      print('Image saved successfully');

      return path.join('assets', 'images', '$userId', '$postId', imageName);
    } catch (e) {
      print('Error saving image: $e');
      // Rethrow the error so it can be handled in the calling code
      throw e;
    }
  }


  Future<void> savePostDataNew(PostItem postItem, File? imageFile) async {
    try {
      final db = await database;

      // Insert the post data without imageURL first to get the auto-incremented ID
      int postId = await db.insert(
        'posts',
        {
          'title': postItem.title,
          'description': postItem.description,
          'imageUrl': null, // Initialize imageURL as null
          'create_time': postItem.createTime.toIso8601String(),
          'user_id': postItem.userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Generate the path using the postId obtained from the database
      String imagePath = '';
      if (imageFile != null) {
        imagePath = await saveImage(imageFile, postItem.userId, postId);
      }

      // Update the post data with the generated imagePath
      await db.update(
        'posts',
        {'imageUrl': imagePath},
        where: 'id = ?',
        whereArgs: [postId],
      );

    } catch (e) {
      print('Error saving post data: $e');
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }


  Future<void> updatePostDataNew(PostItem postItem, File? imageFile) async {
    try {
      final db = await database;

      String imagePath = '';
      if (imageFile != null) {
         imagePath = await saveImage(imageFile, postItem.userId, postItem.id!);
      }
       await db.update(
        'posts',
        {
          'title': postItem.title,
          'description': postItem.description,
          'imageUrl': imagePath,
          'create_time': postItem.createTime.toIso8601String(),
          'user_id': postItem.userId,
        }, where: 'id = ?',
        whereArgs: [postItem.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Generate the path using the postId obtained from the database


    } catch (e) {
      print('Error saving post data: $e');
      rethrow; // Rethrow the error to handle it in the calling code
    }
  }


}
