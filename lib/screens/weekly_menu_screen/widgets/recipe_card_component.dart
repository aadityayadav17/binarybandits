import 'package:flutter/material.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/weekly_menu_screen/widgets/recipe_information_card.dart';

class RecipeImageCard extends StatelessWidget {
  final Recipe recipe;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onRemove;
  final double screenWidth;

  const RecipeImageCard({
    Key? key,
    required this.recipe,
    required this.isSaved,
    required this.onSave,
    required this.onRemove, // Ensure the remove function is accepted
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.9,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                recipe.image,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Remove (Cross) Button at the top-left corner
        Positioned(
          top: 20,
          left: screenWidth * 0.05,
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/recipe_overview_screen/cross.png',
              width: 20,
              height: 20,
            ),
            onPressed: onRemove, // Trigger the remove function
          ),
        ),
        // Save Button at the top-right corner
        Positioned(
          top: 20,
          right: screenWidth * 0.05,
          child: IconButton(
            icon: Image.asset(
              isSaved
                  ? 'assets/icons/screens/recipe_selection_screen/save-on.png'
                  : 'assets/icons/screens/recipe_selection_screen/save.png',
              width: 20,
              height: 20,
            ),
            onPressed: onSave, // Trigger the save function
          ),
        ),
      ],
    );
  }
}

class RecipeCardStack extends StatelessWidget {
  final Recipe recipe;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onRemove;
  final double screenWidth;
  final double cardTopPosition;
  final double cardHeight;
  final ScrollController scrollController;

  const RecipeCardStack({
    Key? key,
    required this.recipe,
    required this.isSaved,
    required this.onSave,
    required this.onRemove,
    required this.screenWidth,
    required this.cardTopPosition,
    required this.cardHeight,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: cardTopPosition,
              child: RecipeImageCard(
                recipe: recipe,
                isSaved: isSaved,
                onSave: onSave,
                onRemove: onRemove,
                screenWidth: screenWidth,
              ),
            ),
          ],
        ),
        RecipeInformationCard(
          key: ValueKey(recipe.id),
          recipe: recipe,
          topPosition: cardTopPosition + 30,
          cardHeight: cardHeight,
          scrollController: scrollController,
          screenWidth: screenWidth,
        ),
      ],
    );
  }
}
