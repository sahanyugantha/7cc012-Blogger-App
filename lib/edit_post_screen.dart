import 'dart:io';
import 'package:blogger/blog_post_item.dart';
import 'package:blogger/DashboardPage.dart';
import 'package:blogger/db/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditPostScreen extends StatefulWidget {
  final PostItem post;
  final String BASE_PATH;

  const EditPostScreen({Key? key, required this.post, required this.BASE_PATH}) : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
 // final String BASE_PATH;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  File? _imageFile;

  bool _hasStoragePermission = false;
  bool _hasCameraPermission = false;
  bool _hasPhotosPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _titleController = TextEditingController(text: widget.post.title);
    _descriptionController = TextEditingController(text: widget.post.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: null, // Allow multiple lines for description
            ),
            SizedBox(height: 16),
            _buildCurrentImageWidget(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updatePost();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentImageWidget() {
    if (_imageFile != null) {
      // Display the selected image
      return Image.file(
        _imageFile!,
        height: 200,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      );
    } else if (widget.post.imageURL.isNotEmpty &&
        widget.post.imageURL.isNotEmpty != "" &&
        widget.post.imageURL != "NA") {
      // Display the current image from post
      String url = '${widget.BASE_PATH}/${widget.post.imageURL}';

      return Image.asset(
        url,
        height: 200,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      );
    } else {
      String placeholder = 'assets/images/no-image.jpg';
      return Image.asset(
        placeholder,
        height: 200,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      );// Placeholder widget if no image URL is available
    }
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _updatePost() async {
    // Retrieve updated values from controllers
    String updatedTitle = _titleController.text;
    String updatedDescription = _descriptionController.text;

    // Perform API call to update post
    try {
      PostItem postItem = PostItem(
          id: widget.post.id,
          title: updatedTitle,
          description: updatedDescription,
          imageURL: widget.post.imageURL,
          userId: widget.post.userId,
          author: widget.post.author,
          createTime: DateTime.now()
      );
      await DatabaseHelper().updatePostDataNew(postItem, _imageFile);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post updated successfully'),
        ),
      );

      // Navigate back to DashboardPage
      Navigator.pop(context);
    } catch (e) {
      // Handle API error (e.g., display error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update post: $e'),
        ),
      );
    }
  }
}
