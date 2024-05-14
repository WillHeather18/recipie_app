import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/recipe_card.dart';
import '../service/recipe_service.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  final RecipeService recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    var username = Provider.of<UserProvider>(context).username;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: recipeService.getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> recipeData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return RecipeCard(recipeData: recipeData, username: username);
              },
            );
          } else {
            return Center(child: Text("No recipes found"));
          }
        },
      ),
    );
  }
}
