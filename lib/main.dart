import 'package:blogger/BlogDB.dart';
import 'package:blogger/blog_post_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final List<PostItem> blogPosts = [];

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
      home: MyHomePageOffline(),
    );
  }
}


