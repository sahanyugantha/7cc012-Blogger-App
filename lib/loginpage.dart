import 'package:blogger/ApiService.dart';
import 'package:blogger/homepage.dart';
import 'package:flutter/material.dart';

import 'blog_post.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {

    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Login')
        ),
        body: Padding (
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // Handle login button press
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) {
                    _showSnackBar('Please enter both email and password.');
                  } else {
                    _performLogin(email, password);
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _performLogin(String email, String password) async {
    try {
      final userData = await ApiService.performLogin(email, password);
      _showSnackBar("Login successfully!");
      // Login successful, navigate to home page
      // Retrieve blog posts data after successful login
      final List<BlogPost> blogPosts = await ApiService.fetchBlogPosts();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
          ),
        ),
      );

    } catch (e) {
      _showSnackBar("Login failed. Please check email and password");
      print("Login failed.. $e");
    }


  }
}