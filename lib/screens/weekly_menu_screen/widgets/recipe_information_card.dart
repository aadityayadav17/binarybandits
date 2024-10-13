import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';

class RecipeInformationCard extends StatefulWidget {
  final Recipe recipe;
  final double topPosition;
  final double cardHeight;
  final ScrollController scrollController;
  final double screenWidth;

  RecipeInformationCard({
    Key? key,
    required this.recipe,
    required this.topPosition,
    required this.cardHeight,
    required this.scrollController,
    required this.screenWidth,
  }) : super(key: ValueKey(recipe.id));

  @override
  _RecipeInformationCardState createState() => _RecipeInformationCardState();
}

class _RecipeInformationCardState extends State<RecipeInformationCard> {
  bool showIngredients = true;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPosition,
      left: widget.screenWidth * 0.08, // Consistent margin from screen edge
      right: widget.screenWidth * 0.08, // Consistent margin from screen edge
      child: SizedBox(
        height: widget.cardHeight,
        width: widget.screenWidth * 0.9, // Consistent width with ImageCard
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.screenWidth * 0.05),
          ),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 12),
                  _buildNutritionRow(),
                  const SizedBox(height: 16),
                  _buildRecipeName(),
                  const SizedBox(height: 8),
                  _buildTags(widget.recipe),
                  const SizedBox(height: 16),
                  _buildToggleButtons(),
                  const SizedBox(height: 16),
                  showIngredients
                      ? _buildIngredientsList(widget.recipe)
                      : _buildStepsList(widget.recipe),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildIconText(
            'assets/icons/screens/recipe_selection_screen/cooking-difficulty-${widget.recipe.difficulty.toLowerCase()}.png',
            capitalizeFirstLetter(widget.recipe.difficulty),
          ),
        ),
        Expanded(
          child: _buildIconText(
            'assets/icons/screens/recipe_selection_screen/time-clock.png',
            '${widget.recipe.totalTime} min',
          ),
        ),
        Expanded(
          child: _buildIconText(
            'assets/icons/screens/recipe_selection_screen/rating.png',
            '${widget.recipe.rating}',
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildIconTextSideBySide(
            'assets/icons/screens/recipe_selection_screen/calories.png',
            '${widget.recipe.energyKcal} kcal',
          ),
        ),
        Expanded(
          child: _buildIconTextSideBySide(
            'assets/icons/screens/recipe_selection_screen/protein.png',
            '${widget.recipe.protein}g Protein',
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeName() {
    return Text(
      widget.recipe.name,
      style: GoogleFonts.robotoFlex(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTags(Recipe recipe) {
    List<Widget> tags = [];
    if (recipe.classification != null && recipe.classification!.isNotEmpty) {
      tags.add(_buildTag(
        capitalizeFirstLetter(recipe.classification!),
        const Color.fromRGBO(73, 160, 120, 1),
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
    return Wrap(spacing: 8.0, runSpacing: 4.0, children: tags);
  }

  Widget _buildIconText(String iconPath, String text) {
    return Column(
      children: [
        Image.asset(iconPath, width: 24, height: 24),
        const SizedBox(height: 8),
        Text(text, style: GoogleFonts.robotoFlex(fontSize: 14)),
      ],
    );
  }

  Widget _buildIconTextSideBySide(String iconPath, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, width: 24, height: 24),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.robotoFlex(fontSize: 14)),
      ],
    );
  }

  Widget _buildTag(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.robotoFlex(color: Colors.black, fontSize: 14)),
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
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey,
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
                    style: GoogleFonts.robotoFlex(fontSize: 16)),
              ),
              Text(ingredients[index]['quantity'] ?? '',
                  style: GoogleFonts.robotoFlex(fontSize: 16)),
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
              Text('${index + 1}.',
                  style: GoogleFonts.robotoFlex(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(recipe.steps[index],
                    style: GoogleFonts.robotoFlex(fontSize: 16)),
              ),
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
