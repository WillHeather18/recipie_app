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
