import 'package:sqflite/sqflite.dart';

class BlogDB {
  static const String postTableName = 'posts';
  static const String userTableName = 'user';
  static const String postLikesTableName = 'post_likes';

  static const String postDetailsViewName = 'post_details';

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

  // Create Post Likes Table
  Future<void> createPostLikesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $postLikesTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        post_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        like_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(post_id, user_id),
        FOREIGN KEY(post_id) REFERENCES $postTableName(id),
        FOREIGN KEY(user_id) REFERENCES $userTableName(id)
      )
    ''');
  }

  Future<void> createPostDetailsView(Database db) async {
    await db.execute('''
    CREATE VIEW IF NOT EXISTS $postDetailsViewName AS
    SELECT
        p.id AS id,
        p.title AS title,
        p.description AS description,
        p.imageUrl AS image,
        COUNT(pl.id) AS likes,
        p.create_time AS create_time,
        p.user_id AS user_id,
        u.username AS username
    FROM
        $postTableName p
    LEFT JOIN
        $postLikesTableName pl ON p.id = pl.post_id
    LEFT JOIN
        $userTableName u ON p.user_id = u.id
    GROUP BY
        p.id,
        p.title,
        p.description,
        p.imageUrl,
        p.create_time,
        p.user_id,
        u.username
    ORDER BY
        p.id DESC;
  ''');
  }



}
