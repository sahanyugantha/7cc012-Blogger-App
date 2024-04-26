

import 'package:blogger/blog_post_item.dart';

import 'db/DatabaseHelper.dart';
import 'UserItem.dart';

Future<void> insertInitialUserData() async {
  try {
    // Get the path to the database file
    // Function to insert user data
    Future<void> insertUserData() async {
      UserItem user1 = UserItem(
      id: 1,
      username: 'sahan',
      email: 'sahan@bcas.lk',
      password: '123',
      createTime: DateTime.parse('2024-04-15 20:41:03'),
      imageURL: 'NA',
      );

      UserItem user2 = UserItem(
      id: 2,
      username: 'perera',
      email: 'sahan@wlv.ac.uk',
      password: '123',
      createTime: DateTime.parse('2024-04-16 21:43:51'),
      imageURL: 'NA',
      );

  // Insert user data into the database
  await DatabaseHelper().createUser(user1);
  await DatabaseHelper().createUser(user2);
  }

  } catch (e) {
    print('Error inserting user data: $e');
  }
}

Future<void> insertInitialPostData() async {
  try {
    // Get the path to the database file
    // Function to insert user data
    Future<void> insertPostData() async {
      PostItem post1 = PostItem(
        id: 1,
        title: 'Test',
        description: 'test d',
        userId: 1,
        author: 'sahan',
        imageURL: '',
        likes: 0,
        likedBy:null,
        createTime: DateTime.now(),
      );


      // Insert user data into the database
      await DatabaseHelper().savePostData(post1);
    }

  } catch (e) {
    print('Error inserting user data: $e');
  }
}

