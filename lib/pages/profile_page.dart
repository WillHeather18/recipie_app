import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../service/user_service.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accessing user data from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final userService = UserService(userProvider: userProvider);

    var followers;// = userProvider.followers;
    var following;// = userService.following;
    var profilePictureUrl = userProvider.profilePictureUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(userProvider.email),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set the background color to red
            ),
            onPressed: () async {
              await userService.signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : null,
                      child: profilePictureUrl.isEmpty
                          ? Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Text(userProvider.username, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("Followers:", style: const TextStyle(fontSize: 20)),
                    Text("${followers ?? 0}", style: const TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  children: [
                    Text("Following:", style: const TextStyle(fontSize: 20)),
                    Text("${following ?? 0}", style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}