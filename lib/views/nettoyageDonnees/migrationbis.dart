import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientKeywordMigrationPage extends StatelessWidget {
  const IngredientKeywordMigrationPage({Key? key}) : super(key: key);

  Future<void> migrateKeywords(BuildContext context) async {
  final collection = FirebaseFirestore.instance.collection('recipes');
  final stopWords = {
    'de', 'et', 'des', 'du', 'la', 'le', 'les', 'à', 'au', 'en', 'avec',
    'mg', 'g', 'gr', 'grammes', 'ml', 'l', 'kg', 'cl', 'cc',
    'cuillères', 'cuillère', 'une', 'un', 'tasse', 'verre'
  };

  final snapshot = await collection.get();
  int updatedCount = 0;

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final ingredients = data['ingredients'];

    if (ingredients is List) {
      final keywords = ingredients
          .map((item) => item
              .toString()
              .toLowerCase()
              .replaceAll(RegExp(r"d['’]", unicode: true), '') 
              .replaceAll(RegExp(r"[^\p{L}\s]", unicode: true), '')) 
          .expand((phrase) => phrase.split(' ')) 
          .where((word) =>
              word.trim().isNotEmpty &&
              !stopWords.contains(word) &&
              !RegExp(r'^\d+$').hasMatch(word)) 
          .toSet()
          .toList();

      await doc.reference.update({'ingredientsMotsCles': keywords});
      updatedCount++;
      print('Mis à jour: $updatedCount');
    }
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Migration terminée. $updatedCount documents mis à jour.')),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Migration des mots-clés')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => migrateKeywords(context),
          child: const Text('Lancer la migration'),
        ),
      ),
    );
  }
}
