import 'package:flutter/material.dart';
import '../service/user_service.dart';
import 'signup.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/add_recipe.dart';

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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                onSubmitted: (_) => _login(),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSubmitted: (_) => _login(),
              ),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text('No account? Sign up'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    try {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      UserService _userService = UserService(userProvider: userProvider);

      await _userService.login(_emailController.text, _passwordController.text);

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
