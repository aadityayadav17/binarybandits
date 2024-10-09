import 'package:flutter/material.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';

class RecipeImageCard extends StatelessWidget {
  final Recipe recipe;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onUndo;
  final double screenWidth;

  const RecipeImageCard({
    Key? key,
    required this.recipe,
    required this.isSaved,
    required this.onSave,
    required this.onUndo,
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
        Positioned(
          top: 20,
          left: screenWidth * 0.05,
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/recipe_selection_screen/undo.png',
              width: 20,
              height: 20,
            ),
            onPressed: onUndo,
          ),
        ),
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
            onPressed: onSave,
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
  final VoidCallback onUndo;
  final double screenWidth;
  final double cardTopPosition;
  final double cardHeight;
  final ScrollController scrollController;

  const RecipeCardStack({
    Key? key,
    required this.recipe,
    required this.isSaved,
    required this.onSave,
    required this.onUndo,
    required this.screenWidth,
    required this.cardTopPosition,
    required this.cardHeight,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardTopPosition + cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RecipeImageCard(
              recipe: recipe,
              isSaved: isSaved,
              onSave: onSave,
              onUndo: onUndo,
              screenWidth: screenWidth,
            ),
          ),
          Positioned(
            top: cardTopPosition - 30, // Adjust this value as needed
            left: 0,
            right: 0,
            child: RecipeInformationCard(
              recipe: recipe,
              topPosition: 0,
              cardHeight: cardHeight,
              scrollController: scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
