import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String uid;
  final String nom;
  final String categorie;
  final int calories;
  final String coutTotal;
  final String coutParPart;
  final String tempsDePreparation;
  final String tempsDeCuisson;
  final List<String> ingredients;
  final List<String> etapes;
  final String image;
  final String url;
  final List<String> ingredientsMotsCles;

  Recipe({
    required this.uid,
    required this.nom,
    required this.categorie,
    required this.calories,
    required this.coutTotal,
    required this.coutParPart,
    required this.tempsDePreparation,
    required this.tempsDeCuisson,
    required this.ingredients,
    required this.etapes,
    required this.image,
    required this.url,
    required this.ingredientsMotsCles
  });

  /// Création d'une instance à partir d'un document Firestore
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<String> etapesList = (data['etapes'] ?? '').toString().split(';').map((e) => e.trim()).toList();
    return Recipe(
      uid: doc.id,
      nom: data['nom'] ?? '',
      categorie: data['categorie'] ?? '',
      calories: extractCalories(data['calories']),
      coutTotal: data['coutTotal'] ?? '',
      coutParPart: data['coutParPart'] ?? '',
      tempsDePreparation: data['tempsDePreparation'] ?? '',
      tempsDeCuisson: data['tempsDeCuisson'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      etapes: etapesList,
      image: data['image'] ?? '',
      url: data['url'] ?? '',
      ingredientsMotsCles: List<String>.from(data['ingredientsMotsCles'] ?? []),
    );
  }


}


int extractCalories(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      return match != null ? int.parse(match.group(1)!) : 0;
    }
    return 0;
  }
