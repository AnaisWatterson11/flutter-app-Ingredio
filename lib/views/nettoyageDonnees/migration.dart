import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';

class MigrationPage extends StatelessWidget {
  const MigrationPage({Key? key}) : super(key: key);

  Future<void> migrateNumberAlphaSep(BuildContext context) async {
    final collection = FirebaseFirestore.instance.collection('recipes');
    final snapshot = await collection.get();

    int updatedCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rawIngredients = data['ingredients'];

      if (rawIngredients is List<dynamic>) {
        // Appliquer la transformation sur chaque élément de la liste d'ingrédients
        final list = rawIngredients.map((ingredient) {
          // Appliquer une expression régulière pour ajouter un espace entre les chiffres et les mots
          final regExp = RegExp(r'(\d+)([a-zA-Z]+)');
          final modifiedIngredient = ingredient.replaceAllMapped(regExp, (match) {
            return '${match.group(1)} ${match.group(2)}'; // Ajoute un espace entre le chiffre et le mot
          });
          return modifiedIngredient;
        }).toList();

        await doc.reference.update({'ingredients': list});
        updatedCount++;
        print(updatedCount);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Migration terminée. $updatedCount documents mis à jour.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migration des ingrédients')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => migrateNumberAlphaSep(context),
          child: const Text('Lancer la migration'),
        ),
      ),
    );
  }
}
