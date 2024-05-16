import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:recipie_app/pages/recipe_page.dart';
import 'package:recipie_app/widgets/search_card.dart';
import '../providers/user_provider.dart';
import '../service/recipe_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
    RecipeService recipeService = RecipeService();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: searchQuery.isEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'This Week\'s Top Recipes',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<QuerySnapshot>(
                              stream: recipeService.getTopLikedRecipes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError ||
                                    !snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text('No top recipes found.'));
                                }

                                final topRecipes = snapshot.data!.docs;

                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: topRecipes.length,
                                    itemBuilder: (context, index) {
                                      final recipeData = topRecipes[index]
                                          .data() as Map<String, dynamic>;

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: SearchCard(
                                          recipeData: recipeData,
                                          heroTag:
                                              "top ${recipeData['imageURL']}",
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Suggested Recipes',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: recipeService.getSuggestedRecipes(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final suggestedRecipes = snapshot.data;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              2, // Creates a 2x2 grid
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 1,
                                        ),
                                        itemCount: suggestedRecipes?.length,
                                        itemBuilder: (context, index) {
                                          final recipeData =
                                              suggestedRecipes?[index];

                                          return SearchCard(
                                            recipeData: recipeData!,
                                            heroTag:
                                                "suggested ${recipeData['imageURL']}",
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: recipeService.searchRecipes(searchQuery),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No recipes found.'));
                          }

                          final searchResults = snapshot.data!.docs;

                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final recipeData = searchResults[index].data()
                                  as Map<String, dynamic>;

                              return SearchCard(
                                recipeData: recipeData,
                                heroTag: "search ${recipeData['imageURL']}",
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
