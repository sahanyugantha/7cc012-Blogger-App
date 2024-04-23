import 'dart:convert';
import 'package:blogger/UserItem.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'BlogDB.dart';
import 'blog_post_item.dart';

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
    final db = await database;
    final List<Map<String, dynamic>> postMaps = await db.query('posts');
    return List.generate(postMaps.length, (index) {
      return PostItem(
        id: postMaps[index]['id'],
        title: postMaps[index]['title'],
        description: postMaps[index]['description'],
        userId: postMaps[index]['user_id'],
        author: postMaps[index]['author'] ?? 'NA',
        imageURL: postMaps[index]['imageUrl'],
        likes: postMaps[index]['likes'] ?? 0,
        likedBy: postMaps[index]['likedBy'] != null
            ? Set<int>.from(postMaps[index]['likedBy'])
            : null,
        createTime: DateTime.parse(postMaps[index]['create_time']),
      );
    });
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

  // Retrieve user data from the database
  Future<UserItem?> getUserData() async {
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

  // Delete User
  Future<int> deleteUser(int id) async {
    final database = await DatabaseHelper().database;
    return await database.delete(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );
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
}
