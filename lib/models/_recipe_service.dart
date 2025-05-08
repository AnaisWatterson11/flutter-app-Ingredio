// lib/services/recipe_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/_recipe.dart';
import 'package:flutter_application_1/models/_recipe_mode.dart';
import 'package:flutter_application_1/utilities/filtering.dart';
import 'package:flutter_application_1/utilities/string_similarity.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchRecipes(
  {
  required List<String> ingredients,
  String? category,
  bool glutenFree = false,
  bool vegetarian = false,
  bool pertePoids = false,
  bool noSugar = false,
  bool noLactose = false,
  bool noFruitsCoque = false,
  bool noArachides = false,
}) async {
  final selectedCollection = (glutenFree || vegetarian) ? 'recipes_mode' : 'recipes';
  Query query = _firestore.collection(selectedCollection);

  if (category != null && category.isNotEmpty) {
    if (category.toLowerCase() == 'autre') {
      query = query.where('categorie', whereNotIn: ['Dessert', 'Plat', 'Entrée']);
    } else {
      query = query.where('categorie', isEqualTo: category);
    }
  }

  final snapshot = await query.get();
  final List<Map<String, dynamic>> results = [];

  for (final doc in snapshot.docs) {
    final data = doc.data();
    dynamic recipe;
    if (selectedCollection == 'recipes') {
      recipe = Recipe.fromFirestore(doc);
    } else {
      recipe = RecipeMode.fromFirestore(doc);
    }

    if (pertePoids && (recipe.calories > 400)) continue;
    if (glutenFree && recipe.mode == "Mode Végetarien") continue;
    if (vegetarian && recipe.mode == "Mode Sans gluten") continue;

    if (noSugar && containsSimilarIngredient(recipe.ingredientsMotsCles, sugaryIngredients)) continue;
    if (noLactose && containsSimilarIngredient(recipe.ingredientsMotsCles, lactoseIngredients)) continue;
    if (noFruitsCoque && containsSimilarIngredient(recipe.ingredientsMotsCles, nutIngredients)) continue;
    if (noArachides && containsSimilarIngredient(recipe.ingredientsMotsCles, peanutIngredients)) continue;

    final matchCount = getSimilarityMatchCount(ingredients, recipe.ingredientsMotsCles);

    if (ingredients.isEmpty || matchCount > 0) {
      results.add({'recipe': recipe, 'matchCount': matchCount});
    }
  }

  if (ingredients.isNotEmpty) {
    results.sort((a, b) => (b['matchCount'] as int).compareTo(a['matchCount'] as int));
  }

  return results;
}


  Future<Map<String, int>> getUserRatings(String userId) async {
    final snapshot = await _firestore
        .collection('feedbacks')
        .where('userId', isEqualTo: userId)
        .get();

    final Map<String, int> ratings = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final recipeId = data['recipeId'];
      final rating = data['rating'];
      if (recipeId != null && rating != null) {
        ratings[recipeId] = rating as int;
      }
    }
    return ratings;
  }

  Future<List<Recipe>> getRecipesByIds(List<String> ids) async {
  List<Recipe> recipes = [];

  for (final uid in ids) {
    DocumentSnapshot recipeDoc =
        await _firestore.collection('recipes').doc(uid).get();

    if (recipeDoc.exists) {
      recipes.add(Recipe.fromFirestore(recipeDoc));
    } else {
      recipeDoc = await _firestore.collection('recipes_mode').doc(uid).get();
      if (recipeDoc.exists) {
        recipes.add(Recipe.fromFirestore(recipeDoc));
      }
    }
  }

  return recipes;
}

}
