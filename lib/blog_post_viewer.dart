import 'package:blogger/blog_post_item.dart';
import 'package:blogger/db/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostViewerPage extends StatelessWidget {
  final PostItem post;
  final String BASE_PATH;

  const PostViewerPage({Key? key, required this.post, required this.BASE_PATH}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // if coverPhotoUrl = null
    String coverPhotoUrl = post.imageURL ?? 'assets/images/no-image.jpg';

    if(post.imageURL == "NA") {
      coverPhotoUrl = 'assets/images/no-image.jpg';
    } else {
      coverPhotoUrl = '$BASE_PATH/${post.imageURL}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Posted by ${post.author}', // Display author's name
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                '${formatDateTime(post.createTime)}', // Display created time
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Image.asset(
                  coverPhotoUrl,
                  fit: BoxFit.fitWidth, // Ensure image fits width of screen
                  errorBuilder: (context, error, stackTrace) {
                    print('IMAGE Error $error');
                    return Image.asset(
                        'assets/images/no-image.jpg',
                        fit: BoxFit.fitWidth,
                    ); // Show icon for failed images
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                post.description,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                'Likes: ${post.likes}',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    // Format the date
    DateFormat dateFormat = DateFormat('EEEE, d\'${_getDaySuffix(dateTime.day)}\' MMMM yyyy');

    // Format the time
    DateFormat timeFormat = DateFormat.jm(); // 'jm' gives time format like 'h:mm a'

    String formattedDate = dateFormat.format(dateTime);
    String formattedTime = timeFormat.format(dateTime);

    return '$formattedDate at $formattedTime';
  }

  // Function to get the correct suffix for the day (e.g., st, nd, rd, th)
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
}
