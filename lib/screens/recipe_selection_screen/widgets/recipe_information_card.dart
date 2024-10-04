import 'package:flutter/material.dart';
import 'package:binarybandits/models/recipe.dart';

class RecipeInformationCard extends StatelessWidget {
  final Recipe recipe;
  final double topPosition;
  final double cardHeight;

  const RecipeInformationCard({
    Key? key,
    required this.recipe,
    required this.topPosition,
    required this.cardHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPosition, // Dynamic top position passed as argument
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          // Make the card scrollable
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: SizedBox(
              height: cardHeight, // Dynamic card height passed as argument
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildIconText(
                              'assets/icons/screens/recipe_selection_screen/cooking-difficulty-${recipe.difficulty.toLowerCase()}.png',
                              capitalizeFirstLetter(recipe.difficulty),
                            ),
                          ),
                          Expanded(
                            child: _buildIconText(
                              'assets/icons/screens/recipe_selection_screen/time-clock.png',
                              '${recipe.totalTime} min',
                            ),
                          ),
                          Expanded(
                            child: _buildIconText(
                              'assets/icons/screens/recipe_selection_screen/rating.png',
                              '${recipe.rating}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildIconTextSideBySide(
                              'assets/icons/screens/recipe_selection_screen/calories.png',
                              '${recipe.energyKcal} kcal',
                            ),
                          ),
                          Expanded(
                            child: _buildIconTextSideBySide(
                              'assets/icons/screens/recipe_selection_screen/protein.png',
                              '${recipe.protein}g Protein',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _buildTags(recipe),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIngredientsList(recipe),
                      const SizedBox(height: 16),
                      const Text(
                        'Cooking Directions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStepsList(recipe),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(String iconPath, String text) {
    return Column(
      children: [
        Image.asset(iconPath, width: 24, height: 24),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildIconTextSideBySide(String iconPath, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, width: 24, height: 24),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  List<Widget> _buildTags(Recipe recipe) {
    List<Widget> tags = [];
    if (recipe.classification != null && recipe.classification!.isNotEmpty) {
      tags.add(_buildTag(
        capitalizeFirstLetter(recipe.classification!),
        Colors.green, // Example: Vegetarian/Vegan
      ));
    }
    if (recipe.allergens != null) {
      tags.addAll(
        recipe.allergens!
            .where((allergen) => allergen.toLowerCase() != 'none')
            .map(
              (allergen) =>
                  _buildTag(capitalizeFirstLetter(allergen), Colors.red),
            ),
      );
    }
    return tags;
  }

  Widget _buildTag(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child:
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 14)),
    );
  }

  Widget _buildIngredientsList(Recipe recipe) {
    final ingredients =
        recipe.ingredientsQuantityInGrams.split('\n').map((line) {
      final parts = line.split(' -> ');
      return {'name': parts[0], 'quantity': parts[1]};
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(ingredients[index]['name'] ?? '',
                      style: const TextStyle(fontSize: 16))),
              Text(ingredients[index]['quantity'] ?? '',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsList(Recipe recipe) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipe.steps.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${index + 1}.', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(recipe.steps[index],
                      style: const TextStyle(fontSize: 16))),
            ],
          ),
        );
      },
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
