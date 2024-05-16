import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipie_app/widgets/search_card.dart';
import '../providers/user_provider.dart';
import '../service/recipe_service.dart';
import '../service/user_service.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    final userService = UserService(userProvider: userProvider);
    final recipeService = RecipeService();

    bool ownAccount = username == userProvider.username;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: userService.getOtherUserDetails(username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Error loading user');
            }
            final userData = snapshot.data!;
            return Text(userData['email'] ?? 'No Email',
                style: const TextStyle(fontSize: 16));
          },
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the background color to red
              ),
              onPressed: () async {
                await userService.signOut();
              },
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userService.getOtherUserDetails(username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading user details'));
          }
          final userData = snapshot.data!;
          final profilePictureUrl = userData['profilePictureUrl'] ?? '';
          final Future<List<String>> followers =
              userService.getFollowersList(username);
          final Future<List<String>> following =
              userService.getFollowingList(username);

          return SingleChildScrollView(
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
                          Text(username, style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<List<String>>(
                        future: followers,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text('Followers: ${snapshot.data?.length}');
                          }
                        },
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          FutureBuilder<List<String>>(
                            future: following,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                    'Following: ${snapshot.data?.length}');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'My Recipes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  FutureBuilder<Stream<QuerySnapshot>>(
                    future: recipeService.getUserRecipes(username),
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
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (streamSnapshot.hasError ||
                              !streamSnapshot.hasData) {
                            return const Center(
                                child: Text('No recipes found.'));
                          }

                          final recipes = streamSnapshot.data?.docs;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
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

                                return Stack(children: [
                                  SearchCard(
                                    recipeData: recipeData,
                                    heroTag: recipeData['imageURL'],
                                  ),
                                  if (ownAccount)
                                    Positioned(
                                      bottom: 7,
                                      right: 7,
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Delete Recipe'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this recipe?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        recipeService
                                                            .deleteRecipe(
                                                                recipe.id);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Delete Recipe'),
                                          ),
                                        ],
                                        child: const Icon(Icons.more_horiz,
                                            color: Colors.white),
                                      ),
                                    )
                                ]);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
