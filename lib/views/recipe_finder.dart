// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/routes.dart';
import 'package:flutter_application_1/models/_recipe_service.dart';
import 'package:flutter_application_1/services/auth/firebase_auth_provider.dart';
import 'package:flutter_application_1/utilities/show_error_dialog.dart';
import 'package:flutter_application_1/views/recipe_detail.dart';
import 'package:flutter_application_1/views/recipeFinder/ingredients_input.dart';
import 'package:flutter_application_1/views/recipeFinder/star_rating.dart';

class RecipeFinderPage extends StatefulWidget {
  const RecipeFinderPage({super.key});

  @override
  State<RecipeFinderPage> createState() => _RecipeFinderPageState();
}

class _RecipeFinderPageState extends State<RecipeFinderPage> {
  final TextEditingController _ingredientController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuthProvider _authProvider = FirebaseAuthProvider();
  final RecipeService _recipeService = RecipeService();

  List<String> _favoriteRecipeIds = [];

    void updateFavoritesList(List<String> updatedFavorites) {
    setState(() {
      _favoriteRecipeIds = updatedFavorites;
    });
  }

  Future<bool> isFavorite(String recipeUid) async {
  final favoriteIds = await _authProvider.getFavorites();
  return favoriteIds.contains(recipeUid);
}
  

  final List<String> _ingredients = [];
  final List<dynamic> _recipes = [];
  final Map<String, int> _recipeMatchCounts = {};
  String? _selectedCategory;
  final List<String> _categories = ['Dessert', 'Plat', 'Entrée', 'Autre'];
  Map<String, int> _userRatings = {};

  bool _isLoadingMore = false;

  bool glutenFree = false;
  bool vegetarian = false;
  bool pertePoids =false;
  bool noSugar = false;
  bool noLactose = false;
  bool noFruitsCoque=false;
  bool noArachides=false;

  @override
  void initState()  {
  super.initState();
  print("initState appelé");
  _scrollController.addListener(_onScroll);
  _loadFavoriteRecipes();
  _loadUserRatings();



}

void _loadFavoriteRecipes() async {
  final favorites = await _authProvider.getFavorites();
  setState(() {
    _favoriteRecipeIds = favorites.toList();
  });
}
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreRecipes();
    }
  }

  Future<void> _loadUserRatings() async {
  
    final user = _authProvider.currentUser?.uid;
  if (user == null) return;

  final ratings = await _recipeService.getUserRatings(user);
  setState(() {
    _userRatings = ratings;
  });
}

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _searchRecipes() {
    setState(() {
      _recipes.clear();
    });
    
    _loadMoreRecipes();
  }



  void _loadMoreRecipes() async {
  if (_isLoadingMore) return;

  setState(() => _isLoadingMore = true);

  try {
    final results = await _recipeService.fetchRecipes(
      ingredients: _ingredients,
      category: _selectedCategory,
      glutenFree: glutenFree,
      vegetarian: vegetarian,
      pertePoids: pertePoids,
      noSugar: noSugar,
      noLactose: noLactose,
      noFruitsCoque: noFruitsCoque,
      noArachides: noArachides,
    );

    setState(() {
      for (var entry in results) {
        final recipe = entry['recipe'];
        final matchCount = entry['matchCount'] as int;

        if (!_recipes.any((r) => r.uid == recipe.uid)) {
          _recipes.add(recipe);
          _recipeMatchCounts[recipe.uid] = matchCount;
        }
      }
    });
  } catch (e) {
    print('Erreur : $e');
  } finally {
    setState(() => _isLoadingMore = false);
  }
}

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recettes Intelligentes 🍲",style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),fontWeight: FontWeight.bold,),),
        backgroundColor: const Color.fromARGB(255, 246, 131, 97),
        actions: [
          IconButton(
           icon: const Icon(Icons.favorite_border),
          onPressed: () {
          Navigator.of(context).pushNamed(favorisRoute);
      },),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            IngredientInput(
              controller: _ingredientController,
              onAdd: _addIngredient,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _ingredients
                .map((e) => Chip(
                label: Text(e),
                onDeleted: () => setState(() => _ingredients.remove(e)),
              ))
            .toList(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
            onPressed: () => setState(() {
              _ingredients.clear();
              glutenFree = false;
              vegetarian = false;
              pertePoids = false;
              noSugar = false;
              noLactose = false;
              noFruitsCoque = false;
              noArachides = false;
              _recipes.clear();
              _recipeMatchCounts.clear();
              _selectedCategory = null;}),
            child: const Text('Tout effacer',style :TextStyle(color: Color.fromARGB(255, 245, 113, 42),fontSize: 16),),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text("Sans gluten"),
                    selected: glutenFree,
                    onSelected: (val){setState(() {
                        glutenFree = val;
                        if (val) {
                          vegetarian = false;
                          }
                        });
                     },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Végétarien"),
                    selected: vegetarian,
                     onSelected: (val) {
                      setState(() {
                        vegetarian = val;
                        if (val) {
                          glutenFree = false;
                          }
                        });
                     },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("perte de poids"),
                    selected: pertePoids,
                     onSelected: (val) {
                      setState(() {
                        pertePoids = val;
                       });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Sans sucre"),
                    selected: noSugar,
                    onSelected: (val) {
                      setState(() {
                        noSugar = val;
                      });
                    },
                  ),
                  const SizedBox(width: 8,),
                  FilterChip(
                    label: const Text("Sans lactose"),
                    selected: noLactose,
                    onSelected: (val) => setState(() => noLactose = val),
                  ),
                  const SizedBox (width:8,),
                  FilterChip(
                    label: const Text("Sans fruits à coque"),
                    selected: noFruitsCoque,
                    onSelected: (val) => setState(() => noFruitsCoque = val),
                  ),
                  const SizedBox(width: 8,),
                  FilterChip(
                    label: const Text("Sans arachides"),
                    selected: noArachides,
                    onSelected: (val) => setState(() => noArachides = val),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
              width: 250, // Vous pouvez ajuster la largeur
              child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 246, 240, 231),
                labelText: "Choisir une catégorie",
                labelStyle: TextStyle(color: const Color.fromARGB(255, 14, 10, 9),fontWeight: FontWeight.bold,),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color.fromARGB(255, 152, 147, 147), width: 2),borderRadius: BorderRadius.circular(10),),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color.fromARGB(255, 109, 101, 93), width: 2),borderRadius: BorderRadius.circular(10),),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),),
            ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
        ),


            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.search,color: Color.fromARGB(255, 255, 255, 255),),
              onPressed: _searchRecipes,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                backgroundColor: const Color.fromARGB(255, 246, 131, 97),
              ),
              label: const Text("Trouver des recettes",style: TextStyle(fontSize: 18, color: Colors.white,)),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _recipes.isEmpty
                  ? !_isLoadingMore
                  ? Center(child: Text("Aucune recette trouvée.",
                style: TextStyle(fontSize: 16,),
              ),
            )
          : Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _recipes.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _recipes.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final recipe = _recipes[index];
                        print("HELLOOO NUMBER 2");
                        print(_userRatings);
                        print('🧑‍💻 Utilisateur connecté : ${_authProvider.currentUser?.uid}');
                        final matchCount = _recipeMatchCounts[recipe.uid] ?? 0;
                       return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailPage(
                                  recipe: recipe,
                                  
                                ),
                              ),
                            );
                          },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               const CircleAvatar(backgroundColor: Colors.deepOrange,child: Icon(Icons.restaurant, color: Colors.white),),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(recipe.nom, style: const TextStyle(fontWeight: FontWeight.bold)),const SizedBox(height: 4),
                                    Text('Ingrédients correspondants : $matchCount',style: const TextStyle(fontSize: 14, color: Colors.grey),),
                                    const SizedBox(height: 4),
                                    
                                    StarRating(
                                      rating: _userRatings[recipe.uid] ?? 0,
                                      
                                    ),
                                 ],
                                ),
                              ),
                            FutureBuilder<bool>(
                        future: isFavorite(recipe.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Icon(Icons.favorite_border, color: Colors.red);
                          }

                          final isFav = snapshot.data ?? false;

                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              try {
                                if (isFav) {
                                  await _authProvider.removeFavorite(recipe.uid);
                                  setState(() {
                                    _favoriteRecipeIds.remove(recipe.uid);
                                  });
                                } else {
                                  await _authProvider.addFavorite(recipe.uid);
                                  setState(() {
                                    _favoriteRecipeIds.add(recipe.uid);
                                  });
                                }
                              } catch (e) {
                                showErrorDialog(context, 'Erreur: $e');
                              }
                            },);})
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}


