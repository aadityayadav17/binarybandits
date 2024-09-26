class Recipe {
  final String id;
  final String name;
  final String ingredients;
  final String ingredientsQuantity;
  final String ingredientsQuantityInGrams;
  final String cookingDirections;
  final List<String> steps;
  final int prepTime;
  final int cookTime;
  final int totalTime;
  final String difficulty;
  final double rating;
  final int protein;
  final int energyKcal;
  final int fat;
  final double saturatedFat;
  final int carbs;
  final int sugar;
  final int sodium;
  final String image;
  final String? classification;
  final List<String>? allergens;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.ingredientsQuantity,
    required this.ingredientsQuantityInGrams,
    required this.cookingDirections,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.totalTime,
    required this.difficulty,
    required this.rating,
    required this.protein,
    required this.energyKcal,
    required this.fat,
    required this.saturatedFat,
    required this.carbs,
    required this.sugar,
    required this.sodium,
    required this.image,
    this.classification,
    this.allergens,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['recipe_id'] as String,
      name: json['recipe_name'] as String,
      ingredients: json['ingredients'] as String,
      ingredientsQuantity: json['ingredients_quantity'] as String,
      ingredientsQuantityInGrams: json['ingredients_quantity_in_g'] as String,
      cookingDirections: json['cooking_directions'] as String,
      steps: _parseSteps(json['cooking_directions'] as String),
      prepTime: json['prep_time_min'] as int,
      cookTime: json['cook_time_min'] as int,
      totalTime: json['total_time_min'] as int,
      difficulty: json['difficulty'] as String,
      rating: (json['rating'] as num).toDouble(),
      protein: json['protein_g'] as int,
      energyKcal: json['energy_kcal'] as int,
      fat: json['fat_g'] as int,
      saturatedFat: (json['saturated_fat_g'] as num).toDouble(),
      carbs: json['carbs_g'] as int,
      sugar: json['sugar_g'] as int,
      sodium: json['sodium_mg'] as int,
      image: json['image'] as String,
      classification: json['classification'] as String?,
      allergens: _parseAllergens(json['allergens']),
    );
  }

  static List<String> _parseSteps(String cookingDirections) {
    return cookingDirections
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  static List<String>? _parseAllergens(dynamic allergens) {
    if (allergens == null || allergens == 'none') {
      return null;
    } else if (allergens is String) {
      return allergens.split(', ');
    } else if (allergens is List) {
      return List<String>.from(allergens);
    } else {
      throw Exception("Unexpected allergens format");
    }
  }
}
