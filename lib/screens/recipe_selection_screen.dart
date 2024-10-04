import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen.dart';

class RecipeSelectionScreen extends StatefulWidget {
  const RecipeSelectionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecipeSelectionScreenState createState() => _RecipeSelectionScreenState();
}

class _RecipeSelectionScreenState extends State<RecipeSelectionScreen> {
  List<Recipe> _recipes = []; // Store loaded recipes
  int _currentRecipeIndex = 0; // Track the current recipe index
  final ScrollController _scrollController = ScrollController();
  List<bool> _savedRecipes = [];
  int _selectedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipes(); // Load recipes from JSON when the screen initializes
  }

  // Load the recipe data from JSON file
  Future<void> _loadRecipes() async {
    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _recipes = jsonData.map((data) => Recipe.fromJson(data)).toList();
      _savedRecipes = List.generate(_recipes.length,
          (_) => false); // Initialize saved state to false for all recipes
    });
  }

  // Move to the next recipe
  void _nextRecipe() {
    setState(() {
      _currentRecipeIndex = (_currentRecipeIndex + 1) % _recipes.length;
    });
    _scrollToTop();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0, // Scroll to the top
      duration: const Duration(milliseconds: 300), // Smooth scroll
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_recipes.isEmpty) {
      return const Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Show loading spinner if recipes are not loaded
      );
    }

    final recipe =
        _recipes[_currentRecipeIndex]; // Get the current recipe to display

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme, // Apply Roboto Flex font globally
        ),
      ),
      home: Scaffold(
        backgroundColor:
            const Color.fromRGBO(245, 245, 245, 1), // Body background color
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(
              245, 245, 245, 1), // Match app bar with body background
          elevation: 0,
          toolbarHeight: 60,
          automaticallyImplyLeading: false, // Disable default leading padding
          leading: Padding(
            padding: const EdgeInsets.only(
                left: 8.0), // Adjusted padding to reduce space
            child: IconButton(
              icon: Image.asset(
                'assets/icons/screens/common/back-key.png',
                width: 24,
                height: 24,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          key: ValueKey<int>(_currentRecipeIndex),
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Reduced spacing between AppBar and main body
                const SizedBox(height: 1),
                // Discover and Recipe Texts with 4 and Selected on new lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Discover\nRecipe",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            letterSpacing: 0,
                            height: 0.9,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$_selectedCount', // Display the current selected count dynamically
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          "Selected",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
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
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20), // To match the card
                          child: Image.asset(
                            recipe.image, // Dynamically load the local image
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Save Button at the top-right corner
                    Positioned(
                      top:
                          20, // Adjust the top position based on how close to the top you want it
                      right:
                          20, // Adjust the right position to align with the right edge
                      child: IconButton(
                        icon: Image.asset(
                          _savedRecipes[_currentRecipeIndex]
                              ? 'assets/icons/screens/recipe_selection_screen/save-on.png'
                              : 'assets/icons/screens/recipe_selection_screen/save.png', // Toggle between save and save-on icons
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _savedRecipes[_currentRecipeIndex] = !_savedRecipes[
                                _currentRecipeIndex]; // Toggle the saved state
                          });
                        },
                      ),
                    ),

                    // Recipe Information Card slightly overlapping the image card
                    Positioned(
                      top:
                          250, // Overlaps the image by 50px as in the original code
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Card(
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
                          child: SizedBox(
                            height:
                                200, // Fixed height as per original specification
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: _buildIconText(
                                                'assets/icons/screens/recipe_selection_screen/cooking-difficulty-${recipe.difficulty.toLowerCase()}.png',
                                                capitalizeFirstLetter(
                                                    recipe.difficulty))),
                                        Expanded(
                                            child: _buildIconText(
                                                'assets/icons/screens/recipe_selection_screen/time-clock.png',
                                                '${recipe.totalTime} min')),
                                        Expanded(
                                            child: _buildIconText(
                                                'assets/icons/screens/recipe_selection_screen/rating.png',
                                                '${recipe.rating}')),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                            child: _buildIconTextSideBySide(
                                                'assets/icons/screens/recipe_selection_screen/calories.png',
                                                '${recipe.energyKcal} kcal')),
                                        Expanded(
                                            child: _buildIconTextSideBySide(
                                                'assets/icons/screens/recipe_selection_screen/protein.png',
                                                '${recipe.protein}g Protein')),
                                      ],
                                    ),
                                    const SizedBox(height: 0),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left:
                                              0.0), // You can adjust the padding value as needed
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          Text(
                                            recipe.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 4.0,
                                            children: [
                                              if (recipe.classification !=
                                                      null &&
                                                  recipe.classification!
                                                      .isNotEmpty)
                                                _buildTag(
                                                  capitalizeFirstLetter(
                                                      recipe.classification!),
                                                  _getTagColor(
                                                      recipe.classification!),
                                                ),
                                              if (recipe.allergens != null)
                                                ...recipe.allergens!
                                                    .where((allergen) =>
                                                        allergen
                                                            .toLowerCase() !=
                                                        'none')
                                                    .map(
                                                        (allergen) => _buildTag(
                                                              capitalizeFirstLetter(
                                                                  allergen),
                                                              _getTagColor(
                                                                  'allergens'),
                                                            )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Inside your build method, after displaying other recipe details
                                    const SizedBox(height: 16),

                                    // Display ingredients in a list format
                                    const Text(
                                      'Ingredients',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Ingredient list
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                                      shrinkWrap:
                                          true, // Ensure it takes the minimum height
                                      itemCount: _parseIngredients(
                                              recipe.ingredientsQuantityInGrams)
                                          .length,
                                      itemBuilder: (context, index) {
                                        final ingredient = _parseIngredients(
                                                recipe
                                                    .ingredientsQuantityInGrams)[
                                            index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  ingredient.name,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Text(
                                                ingredient.quantity,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Display cooking directions as steps
                                    const Text(
                                      'Cooking Directions',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Cooking directions in a list
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                                      shrinkWrap:
                                          true, // Ensure it takes the minimum height
                                      itemCount: recipe.steps.length,
                                      itemBuilder: (context, index) {
                                        final step = recipe.steps[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${index + 1}.', // Display the step number
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  step,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 190), // Add spacing to push the buttons down

                // Done Button and Add/Remove Buttons
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align buttons at the center
                  children: [
                    // Rejected Button with icon background
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _nextRecipe(); // Move to the next recipe on rejection
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove extra padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:
                            Colors.transparent, // Keep background transparent
                        shadowColor:
                            Colors.transparent, // Remove external shadow
                        splashFactory:
                            NoSplash.splashFactory, // Disable ripple effect
                        elevation: 0, // No visual feedback on press
                      ),
                      child: _buildActionIconWithBackground(
                        'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                        'assets/icons/screens/recipe_selection_screen/recipe-rejected.png',
                      ),
                    ),

                    // Add spacing between the buttons
                    const SizedBox(
                        width: 16), // Adjust the width to control the space

                    // Done Button
                    ElevatedButton(
                      onPressed: () {
                        // Handle Done action if needed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(
                            73, 160, 120, 1), // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 12),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Color.fromARGB(
                              255, 255, 255, 255), // Set text color to white
                        ),
                      ),
                    ),

                    // Add spacing between the buttons
                    const SizedBox(
                        width: 20), // Adjust the width to control the space

                    // Accepted Button with icon background
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCount++; // Increment the count when a recipe is accepted
                          _nextRecipe(); // Move to the next recipe on acceptance
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove extra padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:
                            Colors.transparent, // Keep background transparent
                        shadowColor:
                            Colors.transparent, // Remove external shadow
                        splashFactory:
                            NoSplash.splashFactory, // Disable ripple effect
                        elevation: 0, // No visual feedback on press
                      ),
                      child: _buildActionIconWithBackground(
                        'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                        'assets/icons/screens/recipe_selection_screen/recipe-accepted.png',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // Set background to plain white
          type: BottomNavigationBarType
              .fixed, // Ensures equal spacing for all items
          currentIndex: 0, // Default selected index (Home)
          onTap: (index) {
            // Handle button press by index (actions not decided yet)
            switch (index) {
              case 0:
                // Navigate to HomeScreen when Home button is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
                break;
              case 1:
                // Action for Grocery List button
                break;
              case 2:
                // Action for Discover Recipe button
                break;
              case 3:
                // Action for Weekly Menu button
                break;
              default:
                break;
            }
          },
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
                'assets/icons/bottom_navigation/discover-recipe-on.png',
                width: 24,
                height: 24,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/grocery-list-off.png',
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
          width: 62,
          height: 62,
        ),
        // Foreground icon (24x24) with hard alignment using Positioned
        Positioned(
          top: 18, // Adjust the top value to align vertically
          left: 18, // Adjust the left value to align horizontally
          child: Image.asset(
            iconPath,
            width: 20,
            height: 20,
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

  // Helper method to capitalize the first letter of a string
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getTagColor(String classification) {
    if (classification == 'vegetarian') {
      return Colors.yellow; // Yellow for Vegetarian
    } else if (classification == 'vegan') {
      return Colors.green; // Green for Vegan
    } else if (classification == 'allergens') {
      return Colors.red; // Red for Allergens
    } else {
      return Colors.grey; // Default color for unknown classifications
    }
  }

  // Helper method to parse ingredients
  List<Ingredient> _parseIngredients(String ingredientsData) {
    final List<Ingredient> ingredients = [];
    final lines = ingredientsData.split('\n');
    for (var line in lines) {
      final parts = line.split(' -> ');
      if (parts.length == 2) {
        ingredients.add(Ingredient(parts[0], parts[1]));
      }
    }
    return ingredients;
  }
}

// Ingredient class to hold the ingredient name and quantity
class Ingredient {
  final String name;
  final String quantity;

  Ingredient(this.name, this.quantity);
}
