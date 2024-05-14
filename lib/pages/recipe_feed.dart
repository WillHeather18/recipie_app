import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/recipe_card.dart';
import '../service/recipe_service.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  final RecipeService recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    var username = Provider.of<UserProvider>(context).username;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors
              .transparent, // This is to make Scaffold background transparent
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'Discovery'),
                      Tab(text: 'Following'),
                    ],
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.transparent,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      RecipeFeed(username: username, followingPage: false),
                      RecipeFeed(username: username, followingPage: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecipeFeed extends StatelessWidget {
  final String username;
  final bool followingPage;
  final RecipeService recipeService = RecipeService();

  RecipeFeed({required this.username, required this.followingPage});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Stream<QuerySnapshot>>(
      future: recipeService.getRecipes(username, followingPage: followingPage),
      builder: (context, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (futureSnapshot.hasError) {
          if (followingPage) {
            return const Center(child: Text("No recipes from following"));
          } else {
            return const Center(child: Text("Error fetching data"));
          }
        } else {
          return StreamBuilder<QuerySnapshot>(
            stream: futureSnapshot.data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error fetching data"));
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> recipeData = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    return RecipeCard(
                        recipeData: recipeData, username: username);
                  },
                );
              } else {
                if (followingPage) {
                  return const Center(child: Text("No recipes from following"));
                } else {
                  return const Center(child: Text("No recipes found"));
                }
              }
            },
          );
        }
      },
    );
  }
}
