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

// RecipeImageCard
class RecipeImageCard extends StatelessWidget {
  final Recipe recipe;
  final double screenWidth;

  const RecipeImageCard({
    super.key,
    required this.recipe,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Ensure consistent width
        SizedBox(
          width: screenWidth * 0.9, // Same width as RecipeInformationCard
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
                recipe.image, // Image generated using DALL·E 3
                width: double.infinity,
                height: proportionalHeight(context, 320),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// RecipeInformationCard
class RecipeCardStack extends StatelessWidget {
  final Recipe recipe;
  final double screenWidth;
  final double cardTopPosition;
  final double cardHeight;
  final ScrollController scrollController;

  const RecipeCardStack({
    super.key,
    required this.recipe,
    required this.screenWidth,
    required this.cardTopPosition,
    required this.cardHeight,
    required this.scrollController,
  });

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
          screenHeight: MediaQuery.of(context).size.height,
        ),
      ],
    );
  }
}
