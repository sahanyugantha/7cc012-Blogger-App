import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'DatabaseHelper.dart';
import 'blog_post_item.dart';
import 'UserItem.dart';

class BlogDB {
  static const String postTableName = 'posts';
  static const String userTableName = 'user';

  // Create Post Table
  Future<void> createPostTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $postTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        create_time TEXT,
        user_id INTEGER,
        author TEXT
      )
    ''');
  }

  // Create User Table
  Future<void> createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $userTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        create_time TEXT,
        image_url TEXT
      )
    ''');
  }


}
