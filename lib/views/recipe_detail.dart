// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/_feedback.dart';
import 'package:flutter_application_1/models/_feedback_repo.dart';
import 'package:flutter_application_1/models/_recipe.dart';
import 'package:flutter_application_1/utilities/nettoyage_affichage.dart';
import 'package:flutter_application_1/utilities/show_error_dialog.dart';
import 'package:flutter_application_1/services/mode_main_libre/hands_free.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  


  const RecipeDetailPage({
    required this.recipe,
    super.key,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 0;
  final FeedbackRepository _feedbackRepo = FeedbackRepository();
  bool _isRatingLoaded = false;


  Future<void> _loadUserRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final recipeId = widget.recipe.uid;
    if (userId == null) return;

    final rating = await _feedbackRepo.getUserRating(userId, recipeId);
    
      setState(() {
         _rating = rating ?? 0;
        _isRatingLoaded = true;
      });
    
}

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }


 Widget _buildRatingStars() {
  if (!_isRatingLoaded) {
    return const Center(child: CircularProgressIndicator());
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (index) {
      return IconButton(
        icon: Icon(
          index < _rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 30,
        ),
        onPressed: () async {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) return;

          final newRating = index + 1;

          await _feedbackRepo.upsertRating(
            userId: userId,
            recipeId: widget.recipe.uid,
            rating: newRating,
          );

          setState(() {
            _rating = newRating;
          });
        },
      );
    }),
  );
}
  void _sendFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      showErrorDialog(context, "Vous devez être connecté pour envoyer un feedback.");
      return;
    }
    if (feedbackText.isEmpty || _rating == 0) {
      showErrorDialog(context, "Veuillez entrer un texte et noter la recette.");
      return;
    }

    final feedback = RecipeFeedback(
    recipeId: widget.recipe.uid,
    userId: currentUser.uid,
    text: feedbackText,
    rating: _rating,
    timestamp: DateTime.now(),
  );
    
    try {
      await _feedbackRepo.sendFeedback(feedback);
      showDialogMessage(context, "Merci pour votre feedback ! ❤️");
      _feedbackController.clear();


    } catch (e) {
      showErrorDialog(context, "Erreur lors de l'envoi du feedback : $e");
    }
  }

  Widget _buildInfoColumn(IconData icon, String label) {
  return Column(
    children: [
      Icon(icon, size: 28, color: Colors.deepOrange),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    ],
  );
}



  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final cuissonInfo = extractValue(recipe.tempsDeCuisson);
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.nom,style: TextStyle(color: Color.fromARGB(255, 239, 240, 240),),),
        backgroundColor: const Color.fromARGB(255, 246, 131, 97),
      ),
      body: SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (recipe.image != 'Image non trouvée')
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            recipe.image,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Text('Image introuvable'),
          ),
        ),
      const SizedBox(height: 20),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoColumn(Icons.local_fire_department, "${recipe.calories} Kcal"),
          _buildInfoColumn(Icons.timer, recipe.tempsDePreparation),
          _buildInfoColumn(Icons.restaurant, cuissonInfo),
          _buildInfoColumn(Icons.euro, cleanCost(recipe.coutTotal)),
        ],
      ),

      const SizedBox(height: 20),
      const Text("⭐ Noter cette recette :", style: TextStyle(fontSize: 18)),
      _buildRatingStars(),

      const SizedBox(height: 20),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🧾 Ingrédients :", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
              const SizedBox(height: 10),
              ...recipe.ingredients.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text("• $item", style: const TextStyle(fontSize: 17)),
              )),
            ],
          ),
        ),
      ),

      const SizedBox(height: 20),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("👨‍🍳 Préparation :", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.deepOrange)),
              SpeechAssistant(contenu: recipe.etapes),
              ...recipe.etapes.asMap().entries.expand((entry) {
                final parts = entry.value.split('|');
                return parts.map((part) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ", style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: Text(part.trim(), style: const TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ));
              }),
            ],
          ),
        ),
      ),

      const SizedBox(height: 10),
      Container(
        color: Colors.orange.shade50,
        padding: const EdgeInsets.all(12),
        child: const Text(
          "💬 Ton avis :",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _feedbackController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Écris ton feedback ici...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: Colors.orange.shade50,
          filled: true,
        ),
      ),
      const SizedBox(height: 20),
      Center(
        child: ElevatedButton.icon(
          onPressed: _sendFeedback,
          icon: const Icon(Icons.send, color: Colors.white),
          label: const Text("Envoyer le feedback"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 30),
    ],
  ),
),

      
    );
}}
