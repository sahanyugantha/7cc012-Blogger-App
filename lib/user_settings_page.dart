import 'package:blogger/homepage.dart';
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
  final TextEditingController _passwordController = TextEditingController();

  _UserSettingsPageState(this._userData);

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _currentUsername = _userData.username;
    _usernameController.text = _currentUsername;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              const Text(
                'Change Username',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'New Username (min. 3 characters)',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_validateUsername()) {
                    _changeUsername(_userData.id);
                  }
                },
                child: const Text('Change Username'),
              ),
              SizedBox(height: 20),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Current Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  hintText: 'New Password (min. 6 characters)',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_validatePassword()) {
                    _changePassword(_userData.id);
                  }
                },
                child: const Text('Change Password'),
              ),
              SizedBox(height: 20),
              const Text(
                'Delete Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Please enter password for confirmation',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_validateDeleteAccount()) {
                    _deleteUser(_userData.id);
                  }
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

  bool _validateUsername() {
    if (_usernameController.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username must be at least 3 characters'),
        ),
      );
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    if (_oldPasswordController.text.trim().length < 6 ||
        _newPasswordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return false;
    }
    return true;
  }

  bool _validateDeleteAccount() {
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _changeUsername(int id) async {
    String username = _usernameController.text.trim();

    try {
      await ApiService.changeUsername(id, username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username changed successfully. Please log in.'),
        ),
      );
      Navigator.pushReplacement(
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
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    try {
      await ApiService.changePassword(id, oldPassword, newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully. Please log in.'),
        ),
      );
      Navigator.pushReplacement(
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

  Future<void> _deleteUser(int id) async {
    String password = _passwordController.text.trim();
    try {
      await ApiService.deleteUser(id, _userData.email, password)
          .then((_) => ApiService.performLogout()
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully.'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    } catch (e) {
      //print('User deletion failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
        ),
      );
    }
  }
}
