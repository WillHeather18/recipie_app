import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:recipie_app/pages/recipe_page.dart';
import 'package:recipie_app/widgets/search_card.dart';
import '../providers/user_provider.dart';
import '../service/recipe_service.dart';
import '../service/user_service.dart';

class LikesPage extends StatefulWidget {
  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final recipeService = RecipeService();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Recipes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: UserService(userProvider: userProvider)
                    .getLikedList(userProvider.username),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(child: Text('No liked recipes found.'));
                  }

                  final likedList = snapshot.data!;
                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        recipeService.getLikedRecipes(userProvider.username),
                    builder: (context, streamSnapshot) {
                      if (streamSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (streamSnapshot.hasError || !streamSnapshot.hasData) {
                        return const Center(
                            child: Text('No liked recipes found.'));
                      }

                      final likedRecipes = streamSnapshot.data?.docs;

                      // Filter recipes based on search query
                      final filteredRecipes = likedRecipes?.where((recipe) {
                        final recipeData =
                            recipe.data() as Map<String, dynamic>;
                        final title =
                            recipeData['title'].toString().toLowerCase();
                        return title.contains(searchQuery.toLowerCase());
                      }).toList();

                      if (filteredRecipes == null || filteredRecipes.isEmpty) {
                        return const Center(child: Text('No results found.'));
                      }

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
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            final recipeData =
                                recipe.data() as Map<String, dynamic>;

                            return SearchCard(
                              recipeData: recipeData,
                              heroTag: recipeData['imageURL'],
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
