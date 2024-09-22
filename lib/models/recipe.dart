class Recipe {
  final String id;
  final String name;
  final String ingredients;
  final String ingredientsQuantity;
  final String cookingDirections;
  final int prepTime;
  final int cookTime;
  final int totalTime;
  final String difficulty;
  final double rating;
  final int protein;
  final int energyKcal;
  final String image;
  final String? classification; // Classification (Vegan/Vegetarian)
  final List<String>? allergens; // Allergens can be a list or a single string

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.ingredientsQuantity,
    required this.cookingDirections,
    required this.prepTime,
    required this.cookTime,
    required this.totalTime,
    required this.difficulty,
    required this.rating,
    required this.protein,
    required this.energyKcal,
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
      cookingDirections: json['cooking_directions'] as String,
      prepTime: json['prep_time_min'] as int,
      cookTime: json['cook_time_min'] as int,
      totalTime: json['total_time_min'] as int,
      difficulty: json['difficulty'] as String,
      rating: (json['rating'] as num).toDouble(),
      protein: json['protein_g'] as int,
      energyKcal: json['energy_kcal'] as int,
      image: json['image'] as String,
      classification:
          json['classification'] as String?, // Handle classification
      allergens:
          _parseAllergens(json['allergens']), // Handle allergens dynamically
    );
  }

  // Helper method to parse allergens that could be either a string or a list
  static List<String>? _parseAllergens(dynamic allergens) {
    if (allergens == null) {
      return null; // No allergens provided
    } else if (allergens is String) {
      return [allergens]; // Single string allergen, wrap it in a list
    } else if (allergens is List) {
      return List<String>.from(allergens); // List of allergens, return it as is
    } else {
      throw Exception("Unexpected allergens format");
    }
  }
}
