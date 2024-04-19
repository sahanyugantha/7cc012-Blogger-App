import 'dart:io';

import 'package:blogger/userdata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ApiService.dart';
import 'blog_post.dart';
import 'homepage.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile; // Holds the selected image file
  int? _userId; // Holds the logged-in user's ID
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _checkPermission();
  }

  Future<void> _loadUserId() async {
    dynamic userDataString = await ApiService.getUserData();
    UserData userData = UserData.fromJson(userDataString);
    setState(() {
      _userId = userData.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _pickImage(); // Open image picker on tap
                },
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : Placeholder(
                  fallbackHeight: 200.0,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  _submitPost();
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!_hasPermission) {
      // Handle permission denied
      print("NO PERMISSION *****************************");
      return;
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  void _submitPost() {
    // Get values from text controllers
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    print("DATA ************---> title $title description $description userID $_userId");

    // Validate input (add more validation as needed)
   // if (title.isEmpty || description.isEmpty || _imageFile == null || _userId == null) {
    if (title.isEmpty || description.isEmpty || _userId == null) {
      // Handle validation error (show error message)
      _showSnackBar("Please provide title, description, and image.");
      return;
    }

    // Send data to API
    _sendPostToApi(title, description, _imageFile, _userId!);
  }

  void _sendPostToApi(String title, String description, File? imageFile, int userId) {
    ApiService.addPost(title, description, imageFile, userId)
        .then((_) async {
      _showSnackBar("Blog post created!");
      // Clear input fields and image after successful submission
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
      });

      final List<BlogPost> blogPosts = await ApiService.fetchBlogPosts();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            blogPosts: blogPosts,
          ),
        ),
      );
    })
        .catchError((error) {
      _showSnackBar("Failed to create blog post. Error: ${error.toString()}");
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
