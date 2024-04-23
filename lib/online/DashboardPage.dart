import 'package:blogger/online/ApiService.dart';
import 'package:blogger/online/edit_post_screen.dart';
import 'package:blogger/online/userdata.dart';
import 'package:flutter/material.dart';
import 'package:blogger/online/blog_post.dart';
import 'package:intl/intl.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  UserData? _userData;
  List<BlogPost> _userPosts = [];
  Set<BlogPost> _selectedPosts = Set<BlogPost>(); // to select items to delete

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _selectedPosts.isEmpty ? null : _deleteSelectedPosts,
          ),
        ],
      ),
      body: _userData == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _userPosts.isEmpty
          ? Center(
        child: Text(
          "You don't have any posts",
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
          final isSelected = _selectedPosts.contains(post);

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
                    _editPost(post);
                  },
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        _selectedPosts.add(post);
                      } else {
                        _selectedPosts.remove(post);
                      }
                    });
                  },
                ),
              ],
            ),
            onTap: () {
              if (_selectedPosts.isNotEmpty) {
                setState(() {
                  if (isSelected) {
                    _selectedPosts.remove(post);
                  } else {
                    _selectedPosts.add(post);
                  }
                });
              } else {
                _editPost(post);
              }
            },
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

  void _editPost(BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
    ).then((_) {
      _fetchUserPosts(_userData!.id);
    });
  }

  void _deleteSelectedPosts() async {
    for (final post in _selectedPosts) {
      await ApiService.deletePost(post.id);
      setState(() {
        _userPosts.remove(post);
      });
    }
    _selectedPosts.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected posts deleted successfully'),
      ),
    );
  }
}
