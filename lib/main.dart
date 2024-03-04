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
      coverPhotoUrl: 'https://cdn-icons-png.flaticon.com/256/2593/2593549.png/150',
    ),
    BlogPost(
      title: 'Post 2',
      description: 'Description of Post 2',
      coverPhotoUrl: 'https://cdn.icon-icons.com/icons2/560/PNG/512/Blog_icon-icons.com_53707.png/200',
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(0, 223, 200, 99)),
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
      body: ListView.builder(
        itemCount: blogPosts.length,
        itemBuilder: (BuildContext context, int index) {
          String coverPhotoUrl = blogPosts[index].coverPhotoUrl ?? 'https://cdn-icons-png.freepik.com/256/1187/1187595.png/150';
          return ListTile(
              leading: Image.network(
                coverPhotoUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error); // Display a placeholder icon for failed images
                },
              ),
            title: Text(blogPosts[index].title),
            subtitle: Text(blogPosts[index].description),
            onTap: () {
            // Navigate to the detail screen for the selected blog post
            },
          );
        },
      )
    );
  }
}
