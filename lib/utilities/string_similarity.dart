import 'package:string_similarity/string_similarity.dart';

bool isSimilar(String input, String target, {double threshold = 0.8}) {
  final score = StringSimilarity.compareTwoStrings(input.toLowerCase(), target.toLowerCase());
  return score >= threshold;
}

bool containsSimilarIngredient(List<String> inputIngredients, List<String> recipeKeywords, {double threshold = 0.8}) {
  for (final input in inputIngredients) {
    for (final keyword in recipeKeywords) {
      if (isSimilar(input, keyword, threshold: threshold)) return true;
    }
  }
  return false;
}

int getSimilarityMatchCount(List<String> inputIngredients, List<String> recipeIngredients, {double threshold = 0.8}) {
  int count = 0;
  for (final input in inputIngredients) {
    for (final keyword in recipeIngredients) {
      if (isSimilar(input, keyword, threshold: threshold)) {
        count++;
        break;
      }
    }
  }
  return count;
}