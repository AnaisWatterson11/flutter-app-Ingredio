final List<String> sugaryIngredients = ['sucre', 'miel', 'sirop', 'fructose','chocolat','sucré','confiture'];
final List<String> lactoseIngredients = ['lait', 'fromage', 'crème', 'beurre','parmesan', 'yaourt' 'mozzarella', 'cheddar','mascarpone','ricotta'];
final List<String> nutIngredients = ['noisette','amandes', 'noix', 'cajou', 'pistache','pécan','arachides','amande'];
final List<String> peanutIngredients = ['arachide', 'cacahuète','cacahuètes'];

bool containsForbiddenIngredient(List<String> recipeIngredients, List<String> forbiddenIngredients) {
  return forbiddenIngredients.any((forbidden) =>
      recipeIngredients.contains(forbidden.toLowerCase()));
}