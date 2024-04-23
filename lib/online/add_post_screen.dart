import 'dart:io';

import 'package:blogger/online/userdata.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ApiService.dart';
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
  File? _imageFile;
  int? _userId;
  UserData? _userData;
  bool _hasStoragePermission = false;
  bool _hasCameraPermission = false;
  bool _hasPhotosPermission = false;

  @override
  void initState() {
    super.initState();
   // _loadUserId();
    _loadUserData();
    _checkPermissions();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    setState(() {
      _userData = userData;

      String? str = _userData?.id.toString();

      print('USER ID ---------------------> $str');
    });
  }

  Future<void> _loadUserId() async {
    dynamic userDataString = await ApiService.getUserData();
    UserData userData = UserData.fromJson(userDataString);
    _userId = userData.id;
    print('USER ID ---------------------> $_userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _pickImage(ImageSource.gallery);
              },
              child: _imageFile != null
                  ? Image.file(_imageFile!)
                  : Placeholder(
                fallbackHeight: 200.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: const Text('Choose from Gallery'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                  },
                  child: const Text('Take Photo'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                _submitPost();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    bool hasPermission = false;

    if (source == ImageSource.gallery) {
      hasPermission = _hasStoragePermission || _hasPhotosPermission;
    } else if (source == ImageSource.camera) {
      hasPermission = _hasCameraPermission;
    }

    if (!hasPermission) {
      _showSnackBar(
        source == ImageSource.camera ? 'Camera permission required.' : 'Storage permission required.',
      );
      return;
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _checkPermissions() async {
    final storageStatus = await Permission.storage.request();
    final hasStoragePermission = storageStatus.isGranted;

    final cameraStatus = await Permission.camera.request();
    final hasCameraPermission = cameraStatus.isGranted;

    final photosStatus = await Permission.photos.request();
    final hasPhotosPermission = photosStatus.isGranted;

    setState(() {
      _hasStoragePermission = hasStoragePermission;
      _hasCameraPermission = hasCameraPermission;
      _hasPhotosPermission = hasPhotosPermission;
    });
  }

  void _submitPost() {
    _loadUserData();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || _userData == null) {
      print('TITLE  ----- > '+title);
      _showSnackBar('Please provide title');
      return;
    }

    int id = _userData!.id;
    print('ID  ----- > $id');
    _sendPostToApi(title, description, _imageFile, _userData!.id);
  }

  void _sendPostToApi(String title, String description, File? imageFile, int userId) {
    ApiService.addPost(title, description, imageFile, userId).then((_) async {
      _showSnackBar('Blog post created!');
      _clearInputs();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    }).catchError((error) {
      _showSnackBar('Failed to create blog post. Error: ${error.toString()}');
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearInputs() {
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
