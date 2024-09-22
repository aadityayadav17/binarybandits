import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts package
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:binarybandits/models/recipe.dart';

class RecipeSelectionScreen extends StatelessWidget {
  const RecipeSelectionScreen({super.key});

  // Load the recipe data from JSON file
  Future<List<Recipe>> loadRecipes() async {
    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((data) => Recipe.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme, // Apply Roboto Flex font globally
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Body background color
        appBar: AppBar(
          backgroundColor:
              const Color(0xFFF5F5F5), // Match app bar with body background
          elevation: 0,
          toolbarHeight: 60,
          automaticallyImplyLeading: false, // Disable default leading padding
          leading: Padding(
            padding: const EdgeInsets.only(
                left: 8.0), // Adjusted padding to reduce space
            child: IconButton(
              icon: Image.asset(
                'assets/icons/screens/recipe_selection_screen/back-key.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: FutureBuilder<List<Recipe>>(
          future: loadRecipes(), // Load the recipes dynamically from JSON
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // Show loading spinner
            } else if (snapshot.hasError) {
              print(snapshot.error); // Print the error to the console
              return const Center(child: Text('Error loading recipes.'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No recipes available.'));
            }

            final recipes = snapshot.data!;
            final recipe = recipes[0]; // Display the first recipe for now

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // Reduced spacing between AppBar and main body
                    const SizedBox(height: 1),
                    // Discover and Recipe Texts with 4 and Selected on new lines
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Discover\nRecipe",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 36,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "4", // Or dynamically set this value
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Selected",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Keep some spacing here

                    Stack(
                      clipBehavior: Clip.none, // Allows the overlapping effect
                      alignment: Alignment.center, // Centers the stack items
                      children: [
                        // Image Card
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Set width for alignment
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20), // To match the card
                              child: Image.network(
                                recipe.image, // Dynamically load the image
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Recipe Information Card slightly overlapping the image card
                        Positioned(
                          top:
                              220, // This makes the card overlap the image by 50px
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.9, // Same width for alignment
                            child: Card(
                              color: Colors
                                  .white, // Set the card background to plain white
                              elevation: 4,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(20), // Upper left corner
                                  topRight:
                                      Radius.circular(20), // Upper right corner
                                  bottomLeft:
                                      Radius.circular(10), // Lower left corner
                                  bottomRight:
                                      Radius.circular(10), // Lower right corner
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon Row (Easy, Time, Price)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween, // Use spaceBetween for equal separation
                                      children: [
                                        Expanded(
                                          child: _buildIconText(
                                            'assets/icons/screens/recipe_selection_screen/cooking-difficulty-${recipe.difficulty.toLowerCase()}.png',
                                            recipe.difficulty,
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildIconText(
                                            'assets/icons/screens/recipe_selection_screen/time-clock.png',
                                            '${recipe.totalTime} min',
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildIconText(
                                            'assets/icons/screens/recipe_selection_screen/rating.png',
                                            '${recipe.rating}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Calories & Protein Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly, // Distribute space evenly between items
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Center items vertically
                                      children: [
                                        Expanded(
                                          child: _buildIconTextSideBySide(
                                            'assets/icons/screens/recipe_selection_screen/calories.png',
                                            '${recipe.energyKcal} kcal',
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildIconTextSideBySide(
                                            'assets/icons/screens/recipe_selection_screen/protein.png',
                                            '${recipe.protein}g Protein',
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Recipe Name
                                    Align(
                                      alignment: Alignment
                                          .centerLeft, // Aligns the text to the left
                                      child: Text(
                                        recipe.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Display classification and allergens as tags
                                    Align(
                                      alignment: Alignment
                                          .centerLeft, // Ensure tags are left-aligned
                                      child: Wrap(
                                        spacing: 8.0, // Space between tags
                                        runSpacing:
                                            4.0, // Space between rows if tags wrap
                                        children: [
                                          if (recipe.classification != null)
                                            _buildTag(
                                              recipe.classification!,
                                              _getTagColor(
                                                  recipe.classification!),
                                            ),
                                          if (recipe.allergens != null)
                                            ...recipe.allergens!.map(
                                                (allergen) => _buildTag(
                                                    allergen,
                                                    _getTagColor('Allergens'))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 180), // Add spacing to push the buttons down

                    // Done Button and Add/Remove Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Remove button with background
                        _buildActionIconWithBackground(
                          'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                          'assets/icons/screens/recipe_selection_screen/recipe-rejected.png',
                        ),

                        // Done Button
                        ElevatedButton(
                          onPressed: () {
                            // Handle Done action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: const Text('Done'),
                        ),

                        // Add button with background
                        _buildActionIconWithBackground(
                          'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                          'assets/icons/screens/recipe_selection_screen/recipe-accepted.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // Set background to plain white
          type: BottomNavigationBarType
              .fixed, // Ensures equal spacing for all items
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/home-off.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/grocery-list-on.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/discover-recipe-off.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/weekly-menu-off.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
          ],
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }

  // Helper method to build the icon with text below it
  Widget _buildIconText(String iconPath, String text,
      [double? width, double? height]) {
    double iconWidth = width ?? 24;
    double iconHeight = height ?? 24;

    return Column(
      children: [
        Image.asset(
          iconPath,
          width: iconWidth,
          height: iconHeight,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Helper method to build the icon with text next to it (side-by-side)
  Widget _buildIconTextSideBySide(String iconPath, String text) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the content inside the Row
      children: [
        Image.asset(
          iconPath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 8), // Space between icon and text
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  // Helper method to build the icon with a background rectangle and hard alignment
  Widget _buildActionIconWithBackground(
      String backgroundPath, String iconPath) {
    return Stack(
      children: [
        // Rectangle background (60x60)
        Image.asset(
          backgroundPath,
          width: 60,
          height: 60,
        ),
        // Foreground icon (24x24) with hard alignment using Positioned
        Positioned(
          top: 15, // Adjust the top value to align vertically
          left: 15, // Adjust the left value to align horizontally
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }

  // Helper method to build the classification or allergen tag
  Widget _buildTag(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black, // Normal black text
          fontSize: 14,
        ),
      ),
    );
  }

  Color _getTagColor(String classification) {
    if (classification == 'Vegetarian') {
      return Colors.yellow; // Yellow for Vegetarian
    } else if (classification == 'Vegan') {
      return Colors.green; // Green for Vegan
    } else if (classification == 'Allergens') {
      return Colors.red; // Red for Allergens
    } else {
      return Colors.grey; // Default color for unknown classifications
    }
  }
}
