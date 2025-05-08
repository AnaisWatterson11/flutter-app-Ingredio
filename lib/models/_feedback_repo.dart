import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/_feedback.dart';

class FeedbackRepository {
  final _feedbacksRef = FirebaseFirestore.instance.collection('feedbacks');

  Future<int?> getUserRating(String? userId, String recipeId) async {
    final snapshot = await _feedbacksRef
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['rating'] as int;
    }
    return null;
  }

  Future<void> upsertRating({
    required String userId,
    required String recipeId,
    required int rating,
  }) async {
    final feedbackCollection = FirebaseFirestore.instance.collection('feedbacks');

    final existingFeedback = await feedbackCollection
        .where('userId', isEqualTo: userId)
        .where('recipeId', isEqualTo: recipeId)
        .limit(1)
        .get();

    if (existingFeedback.docs.isNotEmpty) {
      // Mettre à jour l'existant
      final docId = existingFeedback.docs.first.id;
      await feedbackCollection.doc(docId).update({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Créer un nouveau document avec le texte vide (ce qui peut être mis à jour plus tard)
      await feedbackCollection.add({
        'userId': userId,
        'recipeId': recipeId,
        'rating': rating,
        'text': '',  // Texte vide par défaut
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> sendFeedback(RecipeFeedback feedback) async {
    final feedbackCollection = FirebaseFirestore.instance.collection('feedbacks');

    // Vérifiez si le feedback pour cette recette et cet utilisateur existe déjà
    final existingFeedback = await feedbackCollection
        .where('userId', isEqualTo: feedback.userId)
        .where('recipeId', isEqualTo: feedback.recipeId)
        .limit(1)
        .get();

    if (existingFeedback.docs.isNotEmpty) {
      // Si le document existe, mettez à jour les champs
      final docId = existingFeedback.docs.first.id;
      await feedbackCollection.doc(docId).update({
        'rating': feedback.rating,
        'text': feedback.text, // Met à jour le texte
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Si le document n'existe pas, créez-en un nouveau avec le texte et la note
      await feedbackCollection.add(feedback.toMap());
    }
  }
}
