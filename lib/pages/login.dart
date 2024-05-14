import 'package:flutter/material.dart';
import '../service/user_service.dart';
import 'signup.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/add_recipe.dart';
import '../pages/main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onSubmitted: (value) async {
                    var loginResult = await _login();
                  },
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSubmitted: (value) async {
                    var loginResult = await _login();
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    var loginResult = await _login();
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                  child: const Text('No account? Sign up'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _login() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      UserService _userService = UserService(userProvider: userProvider);

      await _userService.login(_emailController.text, _passwordController.text);
      return true
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.toString()),
        ),
      );
      return false;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
