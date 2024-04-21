import 'dart:convert';
import 'dart:io';

import 'package:blogger/DashboardPage.dart';
import 'package:blogger/add_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:blogger/loginpage.dart';
import 'package:blogger/userdata.dart';
import 'package:blogger/ApiService.dart';
import 'package:blogger/blog_post.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'blog_post_viewer.dart';


class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<BlogPost> _blogPosts;
  List<BlogPost> _filteredPosts = [];
  UserData? _userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _blogPosts = [];
    _filteredPosts = [];
    _fetchBlogPosts();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    setState(() {
      _userData = userData;
    });
  }

  Future<void> _fetchBlogPosts() async {
    try {
      final List<BlogPost> posts = await ApiService.fetchBlogPosts();
      setState(() {
        _blogPosts = posts;
        _filteredPosts = List.from(posts); // Initialize filtered posts for search
      });
    } catch (e) {
      print('Failed to fetch blog posts: $e');
    }
  }

  //filter posts with user query
  void _filterPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPosts = List.from(_blogPosts); // Reset to all posts
      } else {
        _filteredPosts = _blogPosts
            .where((post) =>
        post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
                delegate: BlogPostSearchDelegate(_blogPosts),
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
                color: Theme.of(context).colorScheme.primary,
              ),
              child: drawerTitle(_userData),
            ),
            if (_userData == null) ...[
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
                  Navigator.pop(context);
                },
              ),
            ] else ...[
              ListTile(
                title: Text('Create Post'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPostPage()),
                  );
                },
              ),
              ListTile(
                title: Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardPage(),
                    ),
                  ).then((_){
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
            ],
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: ListView.builder(
            itemCount: _blogPosts.length,
            itemBuilder: (BuildContext context, int index) {
              // String coverPhotoUrl =
              //     widget.blogPosts[index].imageURL ??
              //         'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';

              final BlogPost post = _blogPosts[index];

              //limit description words to 20
              String limitedDescription = limitWords(post.description, 20);

              //final bool isLiked = post.likedBy!.contains(1);
              final bool isLiked = _userData != null && post.likedBy?.contains(_userData!.id) == true;

              String coverPhotoUrl = "";
              if(_blogPosts[index].imageURL == null || _blogPosts[index].imageURL == "NA"){
                coverPhotoUrl = '${ApiService.baseUrl}/images/no-image.jpg';
              } else {
                coverPhotoUrl = '${ApiService.baseUrl}/${_blogPosts[index].imageURL}';
              }


              return Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey[200],
                  ),
                  child: ListTile(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            child: Image.network(
                              coverPhotoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                    Icons.error); // Show icon for failed images
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          _blogPosts[index].title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(limitedDescription),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleLike(post, isLiked),
                              child: Row(
                                children: [
                              Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
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
                          builder: (context) => PostViewerPage(post: _blogPosts[index]),
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

  Text drawerTitle(UserData? userData) {
    if (userData != null) {
      return Text('Welcome, ${userData.username}!');
    } else {
      return const Text('Please log in to manage blog content.');
    }
  }


  Future<void> _toggleLike(BlogPost post, bool isLiked) async {
    try {
      final userId = _userData?.id; // Use optional chaining for safety

      if (userId != null) {
        final postId = post.id;

        if (isLiked) {
          // Unlike: Remove like association
          await ApiService.removePostLike(postId, userId);
          setState(() {
            post.likedBy!.remove(userId);
            post.likes--;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post unliked'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Like: Add like association
          await ApiService.updatePostLikes(postId, userId);
          setState(() {
            post.likedBy!.add(userId);
            post.likes++;
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
      if (e.toString().contains('404')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove like: Post not found'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to toggle like'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }



  Future<void> _performLogout() async {
    try {
      await ApiService.performLogout();
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


  void _sharePost(BuildContext context, BlogPost post) async {
    String title = post.title; // No need to encode the title for sharing
    String description = post.description;
    String? imageURL = post.imageURL;

    if (imageURL != null) {
      try {
        final temp_imageURL = "${ApiService.baseUrl}/$imageURL";
        final response = await http.get(Uri.parse(temp_imageURL));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          // Get the temporary directory to save the image
          final Directory tempDir = await getTemporaryDirectory();
          final String imagePath = '${tempDir.path}/image.jpg';

          // Write image bytes to the temporary file
          File imageFile = File(imagePath);
          await imageFile.writeAsBytes(bytes);

          // Share the post with the image file
          await Share.shareFiles([imagePath], text: '$title\n$description');
        } else {
          throw Exception('Failed to download image: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sharing post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing post.'),
          ),
        );
      }
    } else {
      // Share post without an image
      await Share.share('$title\n$description');
    }
  }
}


class BlogPostSearchDelegate extends SearchDelegate<String> {
  final List<BlogPost> blogPosts;

  BlogPostSearchDelegate(this.blogPosts);

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

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<BlogPost> suggestions = query.isEmpty
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
                builder: (context) => PostViewerPage(post: suggestions[index]),
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget buildResults(BuildContext context) {
    final List<BlogPost> results = blogPosts.where((post) =>
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
                builder: (context) => PostViewerPage(post: results[index]),
              ),
            );
          },
        );
      },
    );
  }
}

