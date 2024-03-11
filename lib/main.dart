import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class BlogPost {
  final String title;
  final String description;
  final String? coverPhotoUrl;

  BlogPost({
    required this.title,
    required this.description,
    this.coverPhotoUrl,
  });
}

class MyApp extends StatelessWidget {
  // Sample list of blog posts
  final List<BlogPost> blogPosts = [
    BlogPost(
      title: 'Post 1',
      description: 'Description of Post 1',
      coverPhotoUrl: 'https://cdn-icons-png.flaticon.com/256/2593/2593549.png',
    ),
    BlogPost(
      title: 'Post 2',
      description: 'Description of Post 2',
      coverPhotoUrl:
          'https://cdn.icon-icons.com/icons2/560/PNG/512/Blog_icon-icons.com_53707.png',
    ),
    BlogPost(
      title: 'Post 3',
      description: 'Description of Post 3',
    ),
    // Add more blog posts as needed
  ];

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
      home: MyHomePage(blogPosts: blogPosts),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<BlogPost> blogPosts;

  const MyHomePage({super.key, required this.blogPosts});

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
                String coverPhotoUrl = blogPosts[index].coverPhotoUrl ?? 'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';
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
}
