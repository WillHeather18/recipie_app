import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipie_app/widgets/search_card.dart';
import '../providers/user_provider.dart';
import '../service/recipe_service.dart';
import '../service/user_service.dart';
import 'liked_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    // Accessing user data from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final userService = UserService(userProvider: userProvider);
    final recipeService = RecipeService();

    Future<List<String>> followers =
        userService.getFollowersList(userProvider.username);
    Future<List<String>> following =
        userService.getFollowingList(userProvider.username);
    var profilePictureUrl = userProvider.profilePictureUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(userProvider.email, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: InkWell(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              await userService
                                  .uploadProfilePicture(pickedFile.path);
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
                      ),
                      Text(userProvider.username,
                          style: const TextStyle(fontSize: 20)),
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
                    builder: (BuildContext context,
                        AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show a loading spinner while waiting
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Show error if any
                      } else {
                        return Text(
                            'Followers: ${snapshot.data?.length}'); // Display the number of followers
                      }
                    },
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      FutureBuilder(
                          future: following,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<String>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show a loading spinner while waiting
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Show error if any
                            } else {
                              return Text(
                                  'Following: ${snapshot.data?.length}'); // Display the number of following
                            }
                          }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'My Recipes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              FutureBuilder<Stream<QuerySnapshot>>(
                future: recipeService.getUserRecipes(userProvider.username),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('No recipes found.'));
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: snapshot.data,
                    builder: (context, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (streamSnapshot.hasError || !streamSnapshot.hasData) {
                        return const Center(child: Text('No recipes found.'));
                      }

                      final recipes = streamSnapshot.data?.docs;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: recipes?.length ?? 0,
                        itemBuilder: (context, index) {
                          final recipe = recipes![index];
                          final recipeData =
                              recipe.data() as Map<String, dynamic>;

                          return SearchCard(
                            recipeData: recipeData,
                            heroTag: recipeData['imageURL'],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
