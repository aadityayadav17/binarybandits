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
      // Safely cast rating to double, even if it's stored as an int in the JSON
      rating: (json['rating'] as num).toDouble(),
      protein: json['protein_g'] as int,
      energyKcal: json['energy_kcal'] as int,
      image: json['image'] as String,
    );
  }
}
