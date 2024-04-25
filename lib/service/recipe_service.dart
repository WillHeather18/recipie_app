import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeService {
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');

  // Add a new recipe
  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    return recipes
        .add(recipeData)
        .then((value) => print("Recipe Added"))
        .catchError((error) => print("Failed to add recipe: $error"));
  }

  // Get all recipes
  Stream<QuerySnapshot> getRecipes() {
    return recipes.snapshots();
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
}
