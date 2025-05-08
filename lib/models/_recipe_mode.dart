import 'package:cloud_firestore/cloud_firestore.dart';
import '_recipe.dart';

class RecipeMode extends Recipe {
 
  final bool existeDansRecettesOriginales;
  final String mode;

    RecipeMode({
    required super.uid,
    required super.nom,
    required super.categorie,
    required int calories,
    required super.coutParPart,
    required super.coutTotal,
    required super.etapes,
    required this.existeDansRecettesOriginales,
    required super.image,
    required super.ingredients,
    required  this.mode,
    required super.tempsDeCuisson,
    required super.tempsDePreparation,
    required super.url,
    required super.ingredientsMotsCles,
  }) : super(
          calories: extractCalories(calories),
        );

  /// Création à partir d’un document Firestore
  factory RecipeMode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Call the parent class's fromFirestore method
    Recipe recipe = Recipe.fromFirestore(doc);

    // Add extra logic specific to RecipeMode
    return RecipeMode(
      uid: recipe.uid,
      nom: recipe.nom,
      categorie: recipe.categorie,
      calories: recipe.calories,
      coutParPart: recipe.coutParPart,
      coutTotal: recipe.coutTotal,
      etapes: recipe.etapes,
      existeDansRecettesOriginales: data['existeDansRecettesOriginales'] == 'TRUE', // Boolean check
      image: recipe.image,
      ingredients: recipe.ingredients,
      mode: data['mode'] ?? '', // Default to empty string if null
      tempsDeCuisson: recipe.tempsDeCuisson,
      tempsDePreparation: recipe.tempsDePreparation,
      url: recipe.url,
      ingredientsMotsCles: recipe.ingredientsMotsCles,
    );
  }
}
