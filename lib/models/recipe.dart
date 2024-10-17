/// A class representing a recipe with various attributes such as ingredients,
/// cooking directions, nutritional information, and more.
///
/// The [Recipe] class includes methods to convert JSON data into a [Recipe]
/// object and to parse specific fields from the JSON data.
///
/// Attributes:
/// - `id`: Unique identifier for the recipe.
/// - `name`: Name of the recipe.
/// - `ingredients`: Ingredients required for the recipe.
/// - `ingredientsQuantity`: Quantity of ingredients.
/// - `ingredientsQuantityInG`: Quantity of ingredients in grams.
/// - `ingredientsQuantityInGrams`: Quantity of ingredients in grams (duplicate).
/// - `cookingDirections`: Directions for cooking the recipe.
/// - `steps`: List of steps extracted from the cooking directions.
/// - `prepTime`: Preparation time in minutes.
/// - `cookTime`: Cooking time in minutes.
/// - `totalTime`: Total time in minutes (prep time + cook time).
/// - `difficulty`: Difficulty level of the recipe.
/// - `rating`: Rating of the recipe.
/// - `protein`: Protein content in grams.
/// - `energyKcal`: Energy content in kilocalories.
/// - `fat`: Fat content in grams.
/// - `saturatedFat`: Saturated fat content in grams.
/// - `carbs`: Carbohydrate content in grams.
/// - `sugar`: Sugar content in grams.
/// - `sodium`: Sodium content in milligrams.
/// - `image`: URL of the recipe image.
/// - `classification`: Classification of the recipe (optional).
/// - `allergens`: List of allergens present in the recipe (optional).
///
/// Methods:
/// - `Recipe.fromJson(Map<String, dynamic> json)`: Factory constructor to create
///   a [Recipe] object from JSON data.
/// - `_parseSteps(String cookingDirections)`: Static method to parse steps from
///   the cooking directions.
/// - `_parseAllergens(dynamic allergens)`: Static method to parse allergens from
///   the JSON data.
library recipe;

class Recipe {
  final String id;
  final String name;
  final String ingredients;
  final String ingredientsQuantity;
  final String ingredientsQuantityInG;
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
    required this.ingredientsQuantityInG,
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

  // Method to convert JSON data to Recipe object
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['recipe_id'] as String,
      name: json['recipe_name'] as String,
      ingredients: json['ingredients'] as String,
      ingredientsQuantity: json['ingredients_quantity'] as String,
      ingredientsQuantityInG: json['ingredients_quantity_in_g'] as String,
      ingredientsQuantityInGrams:
          json['ingredients_quantity_in_grams'] as String,
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

  // Method to get steps from the JSON data
  static List<String> _parseSteps(String cookingDirections) {
    return cookingDirections
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  // Method to get allergens from the JSON data
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
