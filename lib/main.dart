import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ApiService.dart';
import 'blog_post.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // Fetch list of blog posts from API
  final List<BlogPost> blogPosts = [];

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blogger App by Sahan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(0, 223, 200, 99)),
        useMaterial3: true,
      ),
      home: FutureBuilder<List<BlogPost>>(
        future: ApiService.fetchBlogPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                  final blogPosts = snapshot.data ?? [];
                    return MyHomePage(blogPosts: blogPosts);
                  }
                },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<BlogPost> blogPosts;

  const MyHomePage({Key? key, required this.blogPosts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Blog'),
        ),
        body: Center(
          child: Container(
            width: 600,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: ListView.builder(
              itemCount: blogPosts.length,
              itemBuilder: (BuildContext context, int index) {
                String coverPhotoUrl = blogPosts[index].imageURL ?? 'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[200],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                      // tileColor: Color.fromRGBO(158, 158, 158, 100),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: FractionallySizedBox(
                              // width: MediaQuery.of(context).size.width * 0.8,
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
                          SizedBox(height: 15), // Add some spacing between the image and title
                          Text(
                            blogPosts[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(blogPosts[index].description),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite),
                                onPressed: () {
                                  if(!kIsWeb) { //avoid web browsers.
                                    ScaffoldMessenger.of(context).
                                    showSnackBar(
                                        const SnackBar(
                                          content: Text('Liked'),
                                          duration: Duration(milliseconds: 1000),
                                        )
                                    );
                                    _likePost(context, blogPosts[index].id); // Call like API when button is pressed
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  if(!kIsWeb) { //avoid web browsers.
                                    ScaffoldMessenger.of(context).
                                    showSnackBar(
                                        const SnackBar(
                                          content: Text('Shared'),
                                          duration: Duration(milliseconds: 1000),
                                        )
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        if(!kIsWeb) { //avoid web browsers.
                          ScaffoldMessenger.of(context).
                          showSnackBar(
                              const SnackBar(
                                content: Text('Opening...'),
                                duration: Duration(milliseconds: 500),
                              )
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        )
    );
  }

  void _likePost(BuildContext context, int postId) async {
    try {
      await ApiService.updatePostLikes(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Liked'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like post'),
          duration: Duration(milliseconds: 1000),
        ),
      );
    }
  }
}


