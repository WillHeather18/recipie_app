import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../service/user_service.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Accessing user data from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final userService = UserService(userProvider: userProvider);

    Future<List<String>> followers = userService.getFollowersList(userProvider.username);
    Future<List<String>> following = userService.getFollowingList(userProvider.username);
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
                    InkWell(
                      onTap: () async {
                        final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          await userService.uploadProfilePicture(pickedFile.path);
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: profilePictureUrl.isNotEmpty
                            ? NetworkImage(profilePictureUrl)
                            : null,
                        child: profilePictureUrl.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
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
                FutureBuilder<List<String>>(
                  future: followers, // The Future you want to execute
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show a loading spinner while waiting
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Show error if any
                    } else {
                      return Text('Followers: ${snapshot.data?.length}'); // Display the number of followers
                    }
                  },
                ),
                const SizedBox(width: 40),
                Column(
                  children: [
                    FutureBuilder(future: following,
                    builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show a loading spinner while waiting
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}'); // Show error if any
                      } else {
                        return Text('Following: ${snapshot.data?.length}'); // Display the number of following
                      }
                    }),
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