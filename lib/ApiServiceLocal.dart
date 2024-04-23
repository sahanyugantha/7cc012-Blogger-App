import 'package:blogger/blog_post_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:blogger/online/userdata.dart';

import 'DatabaseHelper.dart';

class ApiServiceLocal {
  // static Future<List<PostItem>> fetchBlogPosts() async {
  //   Database db = await DatabaseHelper().database;
  //   List<Map<String, dynamic>> result = await db.query('posts');
  //
  //   List<PostItem> posts = result.map((data) => PostItem.toList();
  //   UserData? userData = await getUserData();
  //   int? userId = userData?.id;
  //
  //   for (var post in posts) {
  //     post.likedBy = await isPostLiked(post.id, userId);
  //   }
  //   return posts;
  // }
  //
  // static Future<Set<int>> isPostLiked(int postId, int? userId) async {
  //   Database db = await DatabaseHelper().database;
  //   List<Map<String, dynamic>> result = await db.query(
  //     'post_likes',
  //     where: 'post_id = ? AND user_id = ?',
  //     whereArgs: [postId, userId],
  //   );
  //
  //   return result.isNotEmpty ? {postId} : {};
  // }
  //
  // static Future<void> updatePostLikes(int postId, int userId) async {
  //   Database db = await DatabaseHelper().database;
  //   await db.insert('post_likes', {
  //     'post_id': postId,
  //     'user_id': userId,
  //     'like_time': DateTime.now().toIso8601String(),
  //   });
  // }
  //
  // static Future<void> removePostLike(int postId, int userId) async {
  //   Database db = await DatabaseHelper().database;
  //   await db.delete(
  //     'post_likes',
  //     where: 'post_id = ? AND user_id = ?',
  //     whereArgs: [postId, userId],
  //   );
  // }
  //
  // // USER data management
  // static Future<UserData?> getUserData() async {
  //   Database db = await DatabaseHelper().database;
  //   List<Map<String, dynamic>> result = await db.query('user');
  //
  //   if (result.isNotEmpty) {
  //     return UserData.fromJson(result.first);
  //   } else {
  //     return null;
  //   }
  // }
  //
  // static Future<void> saveUserData(UserData? userData) async {
  //   Database db = await DatabaseHelper().database;
  //   await db.insert('user', userData!.toJson(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }
  //
  // // Logout
  // static Future<void> performLogout() async {
  //   _clearLocalSessionData();
  //   // await AuthService.logout();
  // }
  //
  // static void _clearLocalSessionData() {
  //   // _userItem = null;
  // }
}
