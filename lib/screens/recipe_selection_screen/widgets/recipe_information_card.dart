import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts package
import 'package:binarybandits/models/recipe.dart';

class RecipeInformationCard extends StatefulWidget {
  final Recipe recipe;
  final double topPosition;
  final double cardHeight;
  final ScrollController scrollController;
  final double screenWidth; // Add screenWidth parameter

  RecipeInformationCard({
    Key? key,
    required this.recipe,
    required this.topPosition,
    required this.cardHeight,
    required this.scrollController,
    required this.screenWidth, // Add screenWidth to the constructor
  }) : super(key: ValueKey(recipe.id)); // Use recipe.id as the key

  @override
  _RecipeInformationCardState createState() => _RecipeInformationCardState();
}

class _RecipeInformationCardState extends State<RecipeInformationCard> {
  bool showIngredients = true;

  @override
  void didUpdateWidget(RecipeInformationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipe.id != oldWidget.recipe.id) {
      setState(() {
        showIngredients =
            true; // Reset to Ingredients when a new recipe is loaded
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPosition,
      left: 0,
      right: 0,
      child: SizedBox(
        height: widget.cardHeight,
        width: widget.screenWidth * 0.9, // Use screenWidth for card width
        child: Card(
          margin: EdgeInsets.symmetric(
              horizontal:
                  widget.screenWidth * 0.05), // Adjust based on screen width
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
          child: SingleChildScrollView(
            controller: widget.scrollController,
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
                              'assets/icons/screens/recipe_selection_screen/cooking-difficulty-${widget.recipe.difficulty.toLowerCase()}.png',
                              capitalizeFirstLetter(widget.recipe.difficulty))),
                      Expanded(
                          child: _buildIconText(
                              'assets/icons/screens/recipe_selection_screen/time-clock.png',
                              '${widget.recipe.totalTime} min')),
                      Expanded(
                          child: _buildIconText(
                              'assets/icons/screens/recipe_selection_screen/rating.png',
                              '${widget.recipe.rating}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: _buildIconTextSideBySide(
                              'assets/icons/screens/recipe_selection_screen/calories.png',
                              '${widget.recipe.energyKcal} kcal')),
                      Expanded(
                          child: _buildIconTextSideBySide(
                              'assets/icons/screens/recipe_selection_screen/protein.png',
                              '${widget.recipe.protein}g Protein')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.recipe.name,
                    style: GoogleFonts.robotoFlex(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _buildTags(widget.recipe),
                  ),
                  const SizedBox(height: 16),
                  _buildToggleButtons(),
                  const SizedBox(height: 16),
                  if (showIngredients)
                    _buildIngredientsList(widget.recipe)
                  else
                    _buildStepsList(widget.recipe),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        _buildToggleButton('Ingredients', showIngredients),
        const SizedBox(width: 16),
        _buildToggleButton('Steps', !showIngredients),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showIngredients = text == 'Ingredients';
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: GoogleFonts.robotoFlex(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            color: isSelected ? Colors.green : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(Recipe recipe) {
    final ingredients =
        recipe.ingredientsQuantityInGrams.split('\n').map((line) {
      final parts = line.split(' -> ');
      return {'name': parts[0], 'quantity': parts[1]};
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
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
                          style: GoogleFonts.robotoFlex(
                            textStyle: const TextStyle(fontSize: 16),
                          ))),
                  Text(ingredients[index]['quantity'] ?? '',
                      style: GoogleFonts.robotoFlex(
                        textStyle: const TextStyle(fontSize: 16),
                      )),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepsList(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipe.steps.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}.',
                      style: GoogleFonts.robotoFlex(
                        textStyle: const TextStyle(fontSize: 16),
                      )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(recipe.steps[index],
                          style: GoogleFonts.robotoFlex(
                            textStyle: const TextStyle(fontSize: 16),
                          ))),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIconText(String iconPath, String text) {
    return Column(
      children: [
        Image.asset(iconPath, width: 24, height: 24),
        const SizedBox(height: 8),
        Text(text,
            style: GoogleFonts.robotoFlex(
                textStyle: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildIconTextSideBySide(String iconPath, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, width: 24, height: 24),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.robotoFlex(
                textStyle: const TextStyle(fontSize: 14))),
      ],
    );
  }

  List<Widget> _buildTags(Recipe recipe) {
    List<Widget> tags = [];
    if (recipe.classification != null && recipe.classification!.isNotEmpty) {
      tags.add(_buildTag(
        capitalizeFirstLetter(recipe.classification!),
        const Color.fromRGBO(73, 160, 120, 1), // Example: Vegetarian/Vegan
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
      child: Text(text,
          style: GoogleFonts.robotoFlex(
              textStyle: const TextStyle(color: Colors.black, fontSize: 14))),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
