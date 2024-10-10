import 'package:flutter/material.dart';
import 'package:binarybandits/models/recipe.dart';

class RecipeCollectionDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeCollectionDetailScreen({Key? key, required this.recipe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Check if ingredients and steps are strings or lists
            Text(
                'Ingredients: ${recipe.ingredients}'), // Directly use the string if it's not a list
            const SizedBox(height: 8),
            Text(
                'Steps: ${recipe.steps}'), // Directly use the string if it's not a list
          ],
        ),
      ),
    );
  }
}
