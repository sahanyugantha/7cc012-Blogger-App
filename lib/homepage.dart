import 'package:flutter/material.dart';
import 'package:blogger/UserItem.dart';
import 'package:blogger/BlogDB.dart';
import 'package:blogger/blog_post_item.dart';
import 'package:blogger/blog_post_viewer.dart';
import 'package:blogger/loginpage.dart';
import 'package:blogger/user_registration_page.dart';
import 'package:blogger/user_settings_page.dart';
import 'package:blogger/add_post_screen.dart';

import 'DatabaseHelper.dart';

class MyHomePageOffline extends StatefulWidget {
  const MyHomePageOffline({Key? key}) : super(key: key);

  @override
  _MyHomePageOfflineState createState() => _MyHomePageOfflineState();
}

class _MyHomePageOfflineState extends State<MyHomePageOffline> {
  final BlogDB blogDb = BlogDB();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  late Future<List<PostItem>> blogPostsFuture; // Updated to hold the future
  UserItem? _userItem;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserData();
      _fetchBlogPosts(); // Trigger fetching blog posts
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<void> _loadUserData() async {
    final userItem = await DatabaseHelper().getUserData();
    setState(() {
      _userItem = userItem;
    });
  }

  void _fetchBlogPosts() {
    setState(() {
      blogPostsFuture = databaseHelper.getBlogPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: _userItem != null
                  ? drawerTitle(_userItem!)
                  : SizedBox(),
            ),
            if (_userItem == null) ...[
              ListTile(
                title: Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Register'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
              ),
            ] else ...[
              ListTile(
                title: Text('Create Post'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPostPage()),
                  ).then((_) {
                    _fetchBlogPosts();
                  });
                },
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  _performLogout();
                },
              ),
              ListTile(
                title: Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSettingsPage(userData: _userItem!),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder<List<PostItem>>(
          future: blogPostsFuture, // Use blogPostsFuture here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final List<PostItem>? posts = snapshot.data;
              if (posts != null && posts.isNotEmpty) {
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final PostItem post = posts[index];
                    return ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.description),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostViewerPage(post: post),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("No posts available"),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    // Perform logout logic here
    setState(() {
      _userItem = null;
    });
  }

  Widget drawerTitle(UserItem userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, ${userData.username}'),
        Text(userData.email),
      ],
    );
  }
}
