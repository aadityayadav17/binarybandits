import 'package:flutter/material.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';

class RecipeImageCard extends StatelessWidget {
  final Recipe recipe;
  final double screenWidth;

  const RecipeImageCard({
    Key? key,
    required this.recipe,
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
        // The Undo and Save buttons have been removed
      ],
    );
  }
}

class RecipeCardStack extends StatelessWidget {
  final Recipe recipe;
  final double screenWidth;
  final double cardTopPosition;
  final double cardHeight;
  final ScrollController scrollController;

  const RecipeCardStack({
    Key? key,
    required this.recipe,
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
        ),
      ],
    );
  }
}
