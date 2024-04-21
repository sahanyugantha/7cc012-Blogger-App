import 'package:blogger/loginpage.dart';
import 'package:blogger/userdata.dart';
import 'package:flutter/material.dart';

import 'ApiService.dart';

class UserSettingsPage extends StatefulWidget {
  final UserData userData;
  const UserSettingsPage({Key? key, required this.userData}) : super(key: key);

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState(userData);
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final UserData _userData;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  _UserSettingsPageState(this._userData);


  @override
  Widget build(BuildContext context) {
    String _currentUsername = _userData.username;
    _usernameController.text = _currentUsername;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: SingleChildScrollView(
        child : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              const Text(
                'Change Username',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'New Username',
                ),
                controller: _usernameController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle username change logic
                  _changeUsername(_userData.id);
                },
                child: const Text('Change Username'),
              ),
              SizedBox(height: 20),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Current Password',
                ),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  hintText: 'New Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle password change logic
                  _changePassword(_userData.id);
                },
                child: const Text('Change Password'),
              ),
              SizedBox(height: 20),
              const Text(
                'Delete Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Please enter password for confirmation',
                ),
                obscureText: true,
                onChanged: (value) {
                  // Handle changes to the confirmation password
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle account deletion logic
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                    'Delete Account',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeUsername(int id) async {
    // Get user input from text controllers
    String username = _usernameController.text.trim();

    try {
      await ApiService.changeUsername(id, username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username changed successfully. Please log in.'),
        ),
      );
      //Navigator.pop(context); // Navigate back to previous screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Username changing failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username changing failed. Please try again.'),
        ),
      );
    }
  }

  Future<void> _changePassword(int id) async {
    // Get user input from text controllers
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    try {
      await ApiService.changePassword(id, oldPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully. Please log in.'),
        ),
      );
      //Navigator.pop(context); // Navigate back to previous screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Password changing failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changing failed. Please try again.'),
        ),
      );
    }
  }
}
