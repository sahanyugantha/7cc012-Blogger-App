import 'package:blogger/add_post_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:blogger/loginpage.dart';
import 'package:blogger/userdata.dart';
import 'package:blogger/ApiService.dart';
import 'package:blogger/blog_post.dart';

class MyHomePage extends StatefulWidget {
  final List<BlogPost> blogPosts;

  const MyHomePage({
    Key? key,
    required this.blogPosts,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserData? _userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    dynamic userDataString = await ApiService.getUserData();
    print('USER DATA: $userDataString');
    UserData userData = UserData.fromJson(userDataString);
    setState(() {
      _userData = userData;
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
            itemCount: widget.blogPosts.length,
            itemBuilder: (BuildContext context, int index) {
              // String coverPhotoUrl =
              //     widget.blogPosts[index].imageURL ??
              //         'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';

              String coverPhotoUrl = "";
              if(widget.blogPosts[index].imageURL == null || widget.blogPosts[index].imageURL == "NA"){
                coverPhotoUrl = '${ApiService.baseUrl}/images/no-image.jpg';
              } else {
                coverPhotoUrl = '${ApiService.baseUrl}/${widget.blogPosts[index].imageURL}';
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
                          widget.blogPosts[index].title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(widget.blogPosts[index].description),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _likePost(index),
                              child: Row(
                                children: [
                                  Icon(Icons.favorite),
                                  SizedBox(width: 8.0),
                                  Text(widget.blogPosts[index].likes.toString()),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Shared'),
                                    duration: Duration(milliseconds: 1000),
                                  ),
                                );
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

  void _likePost(int index) async {
    try {
      await ApiService.updatePostLikes(widget.blogPosts[index].id);
      setState(() {
        widget.blogPosts[index].likes++; // Increment likes count
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liked'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to like post'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
  }


  void _performLogout() async {
    await ApiService.performLogout();
    setState(() {
      _userData = null;
    });
  }
}
