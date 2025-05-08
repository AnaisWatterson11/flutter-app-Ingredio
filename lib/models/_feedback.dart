class RecipeFeedback {
  final String recipeId;
  final String userId;
  final String text;
  final int rating;
  final DateTime? timestamp;

  RecipeFeedback({
    required this.recipeId,
    required this.userId,
    required this.text,
    required this.rating,
    this.timestamp,
  });

  // Constructeur à partir d'un document Firestore
  factory RecipeFeedback.fromMap(String id, Map<String, dynamic> data) {
    return RecipeFeedback(
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      rating: data['rating'] ?? 0,
      timestamp: data['timestamp']?.toDate(),
    );
  }

  // Conversion pour envoi vers Firestore
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'text': text,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}
