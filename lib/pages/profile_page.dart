import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../service/user_service.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accessing user data from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userService = UserService(userProvider: userProvider);

    var profilePictureUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.account_circle_outlined,
                  size: 100, color: Colors.grey[700]),
            ),
            Text(userProvider.username, style: const TextStyle(fontSize: 20)),
            Text("Email: ${userProvider.email}",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the background color to red
              ),
              onPressed: () async {
                await userService.signOut();
              },
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
