/// A widget that displays an image card for a recipe.
///
/// The [RecipeImageCard] widget shows an image of the recipe inside a card
/// with rounded corners and a shadow effect. The size of the card and the
/// image are proportional to the screen size.
///
/// The [recipe] parameter is the recipe object containing the image path.
/// The [screenWidth] parameter is the width of the screen.

/// A widget that displays a stack of recipe cards, including an image card
/// and an information card.
///
/// The [RecipeCardStack] widget arranges the [RecipeImageCard] and
/// [RecipeInformationCard] in a stack. The image card is positioned at the
/// top, and the information card is positioned below it with a slight overlap.
///
/// The [recipe] parameter is the recipe object containing the details.
/// The [screenWidth] parameter is the width of the screen.
/// The [cardTopPosition] parameter is the top position of the image card.
/// The [cardHeight] parameter is the height of the information card.
/// The [scrollController] parameter is the controller for scrolling the
/// information card.
library recipe_card_components;

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

// Recipe Information Card
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
