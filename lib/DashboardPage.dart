import 'package:blogger/ApiService.dart';
import 'package:blogger/userdata.dart';
import 'package:flutter/material.dart';
import 'package:blogger/blog_post.dart';
import 'package:intl/intl.dart';

import 'edit_post_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserData? _userData;
  List<BlogPost> _userPosts = [];
  int noOfPosts = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    setState(() {
      _userData = userData;
      if (_userData != null) {
        _fetchUserPosts(_userData!.id);
      }
    });
  }

  Future<void> _fetchUserPosts(int userId) async {
    final userPosts = await ApiService.fetchUserPosts(userId);
    setState(() {
      _userPosts = userPosts;
      noOfPosts = _userPosts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: _userData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (noOfPosts <= 0)
          ? const Center(
              child: Text(
                "You don't have any post",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(
                      'Posted on ${_formatDateTime(post.createTime)} by ${post.author}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
                          ).then((_){
                            _fetchUserPosts(post.userId);
                          });;
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(post);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, d\'${_getDaySuffix(dateTime.day)}\' MMMM yyyy \'at\' h:mm a').format(dateTime);
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  void _showDeleteConfirmationDialog(BlogPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deletePost(post);
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePost(BlogPost post) async{
    // Implement post deletion logic (e.g., call API)
    await ApiService.deletePost(post.id);
    setState(() {
      _userPosts.remove(post);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post deleted successfully'),
      ),
    );
  }
}
