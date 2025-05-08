import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/_recipe_service.dart';
import 'package:flutter_application_1/services/auth/firebase_auth_provider.dart';


import 'recipe_detail.dart'; 

import 'package:flutter_application_1/models/_recipe.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
  try {
    final favoriteIds = await _authProvider.getFavorites();
    final recipes = await _recipeService.getRecipesByIds(favoriteIds);

    setState(() {
      _favoriteRecipes = recipes;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Erreur chargement favoris: $e');
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _removeFromFavorites(String recipeId) async {
    await _authProvider.removeFavorite(recipeId);
    setState(() {
      _favoriteRecipes.removeWhere((r) => r.uid == recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Recettes Favorites 🍲",style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),fontWeight: FontWeight.bold,),),
        backgroundColor: const Color.fromARGB(255, 246, 131, 97),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
              ? const Center(child: Text("Aucune recette ajoutée aux favoris",style: TextStyle(fontWeight:FontWeight.bold, )))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: _favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _favoriteRecipes[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.pink),
                        title: Text(recipe.nom),
                        subtitle: Text("Calories : ${recipe.calories} | ${recipe.tempsDeCuisson}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async{  _removeFromFavorites(recipe.uid);
                          setState(() {
    // Met à jour la liste locale si besoin
                            _favoriteRecipes.removeWhere((r) => r.uid == recipe.uid);
                        });}
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

