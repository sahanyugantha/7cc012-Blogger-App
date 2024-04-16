import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ApiService.dart';
import 'blog_post.dart';
import 'homepage.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final List<BlogPost> blogPosts = [];

  MyApp({Key? key});

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


