import 'package:flutter/material.dart';

import '../service/user_service.dart';
import 'login.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png'), // Add this line

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSubmitted: (_) => _signup(),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSubmitted: (_) => _signup(),
                ),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  onSubmitted: (_) => _signup(),
                ),
                ElevatedButton(
                  onPressed: _signup,
                  child: const Text('Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Already have an account? Login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signup() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      UserService _userService = UserService(userProvider: userProvider);

      await _userService.signUp(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Signup Successful'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
