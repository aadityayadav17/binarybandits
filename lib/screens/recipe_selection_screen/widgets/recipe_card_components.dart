import 'package:flutter/material.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';

// Proportional helper functions
double proportionalWidth(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

double proportionalHeight(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.height / 812;
}

double proportionalFontSize(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

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
              borderRadius:
                  BorderRadius.circular(proportionalWidth(context, 20)),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(proportionalWidth(context, 20)),
              child: Image.asset(
                recipe.image,
                width: double.infinity,
                height: proportionalHeight(context, 320),
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
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height:
                  cardTopPosition, // This will push the image down to the specified top position
              child: RecipeImageCard(
                recipe: recipe,
                isSaved: isSaved,
                onSave: onSave,
                onUndo: onUndo,
                screenWidth: screenWidth,
                // Ensures proportional height
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
          screenHeight:
              MediaQuery.of(context).size.height, // Ensures proportional height
        ),
      ],
    );
  }
}
