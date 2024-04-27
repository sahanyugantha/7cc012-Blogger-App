import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:blogger/UserItem.dart';
import 'package:blogger/blog_post_item.dart';
import 'package:blogger/db/DatabaseHelper.dart';
import 'package:blogger/user_registration_page.dart';
import 'package:blogger/user_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:blogger/loginpage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';

import 'DashboardPage.dart';
import 'add_post_screen.dart';
import 'blog_post_viewer.dart';
import 'db/BlogDB.dart';

class MyHomePageOffline extends StatefulWidget {
  const MyHomePageOffline({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePageOffline> {
  late List<PostItem> _blogPosts;
  List<PostItem> _filteredPosts = [];
  UserItem? _userData;
  late String BASE_PATH;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    BASE_PATH = await DatabaseHelper().getBasePath();
     print("BASE PATH ---------> $BASE_PATH");
    await _loadUserData();
    await _fetchBlogPosts();

  }

  Future<String> getBasePath() async {
    return await getApplicationDocumentsDirectory().toString();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await DatabaseHelper().getUserData();
      setState(() {
        _userData = userData;
        int? id = _userData?.id;
        print('USER ----> $id');
        _isLoggedIn = userData != null;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }


  Future<void> _fetchBlogPosts() async {
    try {
      final List<PostItem> blogPosts = await DatabaseHelper().fetchPostsFromView();
      for(PostItem postItem in blogPosts){
        String obj = postItem.title;
        String a = postItem.author;
        print("POST ----> $obj");
      }

      setState(() {
        _blogPosts = blogPosts.map((post) {
          print(post.toString());
          // Initialize likedBy list based on post.likedBy
          Set<int> likedBySet = post.likedBy != null ? Set<int>.from(post.likedBy!) : {}; // Initialize as an empty set if null
          post.likedBy = likedBySet; // Assign the initialized set directly
          return post;
        }).toList();
        //_blogPosts = blogPosts;
       _filteredPosts = List.from(_blogPosts);
      });
    } catch (e) {
      print('Error fetching blog posts: $e');
    }
  }

  void _filterPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = List.from(_blogPosts); // Reset to all posts
      } else {
        _filteredPosts = _blogPosts.where((post) =>
        post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.description.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Blog'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BlogPostSearchDelegate(_blogPosts, BASE_PATH),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: _userData != null
                  ? drawerTitle(_userData!)
                  : SizedBox(),
            ),
            if (_userData == null) ...[
              ListTile(
                title: Text('Login'),
                leading: Icon(Icons.login),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Register'),
                leading: Icon(Icons.person_add),
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
                leading: Icon(Icons.note_add),
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
                title: Text('Dashboard'),
                leading: Icon(Icons.dashboard),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage(BASE_PATH: BASE_PATH)),
                  ).then((_) {
                    _fetchBlogPosts();
                  });
                },
              ),
              ListTile(
                title: Text('Logout'),
                leading: Icon(Icons.logout),
                onTap: () {
                  _performLogout();
                },
              ),
              ListTile(
                title: Text('Settings'),
                leading: Icon(Icons.settings),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSettingsPage(userData: _userData!),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: ListView.builder(
            itemCount: _filteredPosts.length,
            itemBuilder: (BuildContext context, int index) {

              final PostItem post = _filteredPosts[index];
              String coverPhotoUrl = post.imageURL ?? 'assets/images/no-image.jpg';

              if(post.imageURL == "NA") {
                 coverPhotoUrl = 'assets/images/no-image.jpg';
              } else {
                 coverPhotoUrl = '$BASE_PATH/${post.imageURL}';
              }

              final bool isLiked = _userData != null && post.likedBy?.contains(_userData!.id) == true;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[200],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Image.asset(
                              coverPhotoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/no-image.jpg');
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          post.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(limitWords(post.description, 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleLike(post, context),
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked? Colors.red : Colors.grey,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(post.likes.toString()),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                _sharePost(context, post);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening...'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostViewerPage(post: post, BASE_PATH: BASE_PATH,),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget drawerTitle(UserItem userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Welcome, ${userData.username}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          userData.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }


  Future<void> _toggleLike(PostItem post, BuildContext context) async {
    try {
      final userId = _userData?.id; // Use optional chaining for safety

      if (userId != null) {
        final postId = post.id;

        // Check if the user has already liked the post
        final bool isLiked = post.likedBy?.contains(userId) ?? false;

        if (isLiked) {
          // Unlike: Remove like association
          await DatabaseHelper().removePostLike(postId!, userId);
          setState(() {
            post.likedBy?.remove(userId);
            post.likes = (post.likes ?? 0) - 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post unliked'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Like: Add like association
          await DatabaseHelper().savePostLike(postId!, userId);
          setState(() {
            post.likedBy?.add(userId);
            post.likes = (post.likes ?? 0) + 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post liked'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Failed to toggle like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to toggle like'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _performLogout() async {
    try {
      await DatabaseHelper().performLogout();
      setState(() {
        _userData = null; // Clear user data after logout
        _blogPosts.forEach((post) {
          post.likedBy?.clear(); // Clear likedBy lists after logout
        });
      });
    } catch (e) {
      print('Failed to perform logout: $e');
    }
  }


  // Function to limit the number of words displayed
  String limitWords(String input, int wordLimit) {
    List<String> words = input.split(' ');
    if (words.length <= wordLimit) {
      return input;
    } else {
      return words.sublist(0, wordLimit).join(' ') + ' ...';
    }
  }

  void _sharePost(BuildContext context, PostItem post) {
    // Implement post sharing logic here
    // Use Share.share to share post content and image if available
  }
}

class BlogPostSearchDelegate extends SearchDelegate<String> {
  final List<PostItem> blogPosts;
  final String BASE_PATH;

  BlogPostSearchDelegate(this.blogPosts, this.BASE_PATH);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  // Function to limit the number of words displayed
  String limitWords(String input, int wordLimit) {
    List<String> words = input.split(' ');
    if (words.length <= wordLimit) {
      return input;
    } else {
      return words.sublist(0, wordLimit).join(' ') + ' ...';
    }
  }

  // Future<void> _refreshBlogPosts() async {
  //   await _fetchBlogPosts(); // Fetch updated blog posts
  // }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<PostItem> suggestions = query.isEmpty
        ? [] // If query is empty, show no suggestions
        : blogPosts.where((post) =>
    post.title.toLowerCase().contains(query.toLowerCase()) ||
        post.description.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        // Limit the number of words displayed in the description
        String limitedDescription = limitWords(suggestions[index].description, 10);
        return ListTile(
          title: Text(suggestions[index].title),
          subtitle: Text(limitedDescription),
          onTap: () {
            close(context, suggestions[index].title);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostViewerPage(post: suggestions[index], BASE_PATH: BASE_PATH,),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget buildResults(BuildContext context) {
    final List<PostItem> results = blogPosts.where((post) =>
    post.title.toLowerCase().contains(query.toLowerCase()) ||
        post.description.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        // Limit the number of words displayed in the description
        String limitedDescription = limitWords(results[index].description, 15);
        return ListTile(
          title: Text(results[index].title),
          subtitle: Text(limitedDescription),
          onTap: () {
            close(context, results[index].title);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostViewerPage(post: results[index], BASE_PATH: BASE_PATH,),
              ),
            );
          },
        );
      },
    );
  }
}
