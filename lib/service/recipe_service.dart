import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipie_app/service/user_service.dart';
import '../providers/user_provider.dart';

class RecipeService {
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Add a new recipe
  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    return recipes
        .add(recipeData)
        .then((value) => print("Recipe Added"))
        .catchError((error) => print("Failed to add recipe: $error"));
  }

  // Get all recipes
  Future<Stream<QuerySnapshot>> getRecipes(String username,
      {bool followingPage = false}) async {
    if (followingPage) {
      print("Getting following recipes");

      // Get the current user's following list
      List<String> followingList =
          await UserService(userProvider: UserProvider())
              .getFollowingList(username);

      print("Following list: $followingList");

      // Use the 'whereIn' operator to get recipes from the users that the current user is following
      return recipes
          .where('author.username', whereIn: followingList)
          .snapshots();
    } else {
      return recipes.orderBy('datePosted', descending: true).snapshots();
    }
  }
  Future<Stream<QuerySnapshot>> getUserRecipes(String username) async {
    return FirebaseFirestore.instance
        .collection('recipes')
        .where('author.username', isEqualTo: username)
        .snapshots();
  }

  Stream<QuerySnapshot> searchRecipes(String searchString) {
    print('searchRecipes called with searchString: $searchString');

    // Convert the search string to lowercase to make the search case-insensitive
    String lowerCaseSearchString = searchString.toLowerCase();

    // Get all recipes that start with the search string
    Stream<QuerySnapshot> query = recipes
        .orderBy('lowercaseTitle')
        .where('lowercaseTitle', isGreaterThanOrEqualTo: lowerCaseSearchString)
        .where('lowercaseTitle', isLessThan: lowerCaseSearchString + 'z')
        .snapshots();

    return query;
  }

  Stream<QuerySnapshot> getTopLikedRecipes() {
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

    return recipes
        .where('datePosted', isGreaterThan: Timestamp.fromDate(oneWeekAgo))
        .orderBy('interactions.likes', descending: true)
        .limit(5)
        .snapshots();
  }

  // Get suggested recipes
  Future<List<Map<String, dynamic>>> getSuggestedRecipes() async {
    List<Map<String, dynamic>> suggestedRecipes = [];

    // Get all recipes
    QuerySnapshot snapshot = await recipes.get();

    // Check if there are enough recipes to suggest
    if (snapshot.docs.length >= 4) {
      // Generate 4 random indices
      List<int> randomIndices = [];
      while (randomIndices.length < 4) {
        int randomIndex = Random().nextInt(snapshot.docs.length);
        if (!randomIndices.contains(randomIndex)) {
          randomIndices.add(randomIndex);
        }
      }

      // Get the random recipes
      for (int index in randomIndices) {
        DocumentSnapshot doc = snapshot.docs[index];
        Map<String, dynamic> recipe = doc.data() as Map<String, dynamic>;
        suggestedRecipes.add(recipe);
      }
    }

    return suggestedRecipes;
  }

  // Get liked recipes
  Stream<QuerySnapshot> getLikedRecipes(String username) async* {
    List<String> likedList =
        await UserService(userProvider: UserProvider()).getLikedList(username);
    yield* recipes.where('recipeId', whereIn: likedList).snapshots();
  }

  // Update an existing recipe
  Future<void> updateRecipe(
      String documentId, Map<String, dynamic> updatedData) async {
    return recipes
        .doc(documentId)
        .update(updatedData)
        .then((value) => print("Recipe Updated"))
        .catchError((error) => print("Failed to update recipe: $error"));
  }

  // Delete a recipe
  Future<void> deleteRecipe(String documentId) async {
    return recipes
        .doc(documentId)
        .delete()
        .then((value) => print("Recipe Deleted"))
        .catchError((error) => print("Failed to delete recipe: $error"));
  }

  // Add a like to a recipe
  Future<void> addLike(
    String recipeId,
    String username,
  ) async {
    QuerySnapshot userQuery =
        await users.where('username', isEqualTo: username).get();

    if (userQuery.docs.isEmpty) {
      print("No user found with username: $username");
      return;
    }

    DocumentSnapshot userDoc = userQuery.docs[0];
    List<dynamic> likes =
        (userDoc.data() as Map<String, dynamic>)['likes'] ?? [];

    bool alreadyLiked = likes.contains(recipeId);
    if (alreadyLiked) {
      // Unlike the post
      likes.remove(recipeId);
      await userDoc.reference.update({'likes': likes});

      QuerySnapshot recipeQuery =
          await recipes.where('recipeId', isEqualTo: recipeId).get();
      if (recipeQuery.docs.isNotEmpty) {
        await recipeQuery.docs[0].reference
            .update({'interactions.likes': FieldValue.increment(-1)});
        print("Like Removed");
      } else {
        print("No document found with recipeId: $recipeId");
      }
    } else {
      // Like the post
      likes.add(recipeId);
      await userDoc.reference.update({'likes': likes});

      QuerySnapshot recipeQuery =
          await recipes.where('recipeId', isEqualTo: recipeId).get();
      if (recipeQuery.docs.isNotEmpty) {
        await recipeQuery.docs[0].reference
            .update({'interactions.likes': FieldValue.increment(1)});
        print("Like Added");
      } else {
        print("No document found with recipeId: $recipeId");
      }
    }
  }
}
