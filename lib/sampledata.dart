import 'blog_post.dart';

final List<BlogPost> blogPosts = [
  BlogPost(
    id:0,
    title: 'Post 1',
    description: 'Description of Post 1',
    author: "sahan",
    imageURL: 'https://cdn-icons-png.flaticon.com/256/2593/2593549.png',
    createTime: DateTime.now(),
    userId: 1,
  ),
  BlogPost(
    id: 1,
    title: 'Post 2',
    description: 'Description of Post 2',
    author: "sahan",
    imageURL:
    'https://cdn.icon-icons.com/icons2/560/PNG/512/Blog_icon-icons.com_53707.png',
    createTime: DateTime.now(),
    userId: 1,
  ),
  BlogPost(
    id:2,
    title: 'Post 3',
    description: 'Description of Post 3',
    author: "sahan",
    createTime: DateTime.now(),
    userId: 1,
  ),
  // Add more blog posts as needed
];