/// A widget that displays a recipe image card with proportional dimensions.
///
/// The [RecipeImageCard] widget is a stateless widget that takes a [Recipe] object
/// and the screen width as parameters. It displays the recipe image inside a card
/// with rounded corners and proportional dimensions based on the screen size.
///
/// Parameters:
/// - [recipe]: The [Recipe] object containing the recipe details.
/// - [screenWidth]: The width of the screen to calculate proportional dimensions.

/// A widget that displays a stack of recipe cards with proportional dimensions.
///
/// The [RecipeCardStack] widget is a stateless widget that takes a [Recipe] object,
/// screen width, card top position, card height, and a scroll controller as parameters.
/// It displays a stack of recipe cards with the recipe image on top and the recipe
/// information card below it. The dimensions are calculated proportionally based on
/// the screen size.
///
/// Parameters:
/// - [recipe]: The [Recipe] object containing the recipe details.
/// - [screenWidth]: The width of the screen to calculate proportional dimensions.
/// - [cardTopPosition]: The top position of the card stack.
/// - [cardHeight]: The height of the card.
/// - [scrollController]: The scroll controller for the recipe information card.
library recipe_card_component;

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

// Add controller to constructor
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

// Add controller to constructor
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
              height: proportionalHeight(context, cardTopPosition),
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
          topPosition: proportionalHeight(context, cardTopPosition + 30),
          cardHeight: proportionalHeight(context, cardHeight),
          scrollController: scrollController,
          screenWidth: proportionalWidth(context, screenWidth),
          screenHeight: MediaQuery.of(context).size.height,
        ),
      ],
    );
  }
}
