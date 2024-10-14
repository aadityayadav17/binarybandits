import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class IngredientListPage extends StatefulWidget {
  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  List<Recipe> recipes = [];
  Recipe? selectedRecipe;
  bool isAllSelected = true;
  Map<String, bool> selectedIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    // Ensure the user is authenticated
    if (user == null) {
      print('User is not authenticated');
      return;
    }

    // Fetch the user's weekly menu from Firebase using dynamic user ID
    final userId = user.uid; // Dynamic user ID
    final databaseRef =
        FirebaseDatabase.instance.ref("users/$userId/recipeWeeklyMenu");
    final snapshot = await databaseRef.get();

    // Check if there is data in the snapshot
    if (snapshot.exists) {
      final weeklyMenuData = snapshot.value as Map<dynamic, dynamic>;

      // Filter recipes that are accepted
      final acceptedRecipes = weeklyMenuData.values
          .where((recipe) => recipe['accepted'] == true)
          .map((recipe) => recipe['id']) // Recipe ID in Firebase
          .toList();

      // Load recipes from JSON
      final String jsonString = await rootBundle
          .loadString('assets/recipes/D3801 Recipes - Recipes.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      // Filter JSON data based on accepted recipe IDs (Firebase ID is 'id', JSON ID is 'recipe_id')
      final matchedRecipes = jsonData.where((recipeData) {
        return acceptedRecipes
            .contains(recipeData['recipe_id']); // JSON recipe_id
      }).toList();

      setState(() {
        recipes = matchedRecipes.map((data) => Recipe.fromJson(data)).toList();
        _updateAllIngredients();
      });
    } else {
      print('No weekly menu data available.');
    }
  }

  void _updateAllIngredients() {
    Set<String> allIngredients = {};
    for (var recipe in recipes) {
      allIngredients.addAll(
          _parseIngredientsQuantityInG(recipe.ingredientsQuantityInGrams));
    }
    for (var ingredient in allIngredients) {
      if (!selectedIngredients.containsKey(ingredient)) {
        selectedIngredients[ingredient] = false;
      }
    }
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      selectedIngredients[ingredient] =
          !(selectedIngredients[ingredient] ?? false);
    });
  }

  int _getSelectedItemsCount() {
    return selectedIngredients.values.where((isSelected) => isSelected).length;
  }

  // Proportional width based on screen size
  double proportionalWidth(double width) {
    return width * MediaQuery.of(context).size.width / 375;
  }

  // Proportional height based on screen size
  double proportionalHeight(double height) {
    return height * MediaQuery.of(context).size.height / 812;
  }

  // Proportional font size based on screen size
  double proportionalFontSize(double fontSize) {
    return fontSize * MediaQuery.of(context).size.width / 375;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Proportional sizing functions
    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
    double proportionalWidth(double size) => size * screenWidth / 375;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: proportionalHeight(60),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: proportionalWidth(8)),
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/common/back-key.png',
              width: proportionalWidth(24),
              height: proportionalHeight(24),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: proportionalWidth(16),
              top: proportionalHeight(10),
              bottom: proportionalHeight(16),
            ),
            child: Text(
              "Ingredient List",
              style: GoogleFonts.robotoFlex(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: proportionalFontSize(32),
                height: 0.9,
              ),
            ),
          ),
          _buildRecipeTabs(screenWidth),
          SizedBox(height: proportionalHeight(16)),
          Expanded(
            child: _buildIngredientCard(screenWidth, screenHeight),
          ),
          Padding(
            padding: EdgeInsets.all(proportionalWidth(16)),
            child: ElevatedButton(
              onPressed: () {
                // Add selected ingredients to grocery list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                minimumSize: Size(double.infinity, proportionalHeight(50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(proportionalWidth(10)),
                ),
              ),
              child: Text(
                'Add to Grocery List',
                style: GoogleFonts.robotoFlex(
                  color: Colors.white,
                  fontSize: proportionalFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildIngredientCard(double screenWidth, double screenHeight) {
    List<String> ingredients = _getIngredientsList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: proportionalWidth(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(proportionalWidth(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(proportionalWidth(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: proportionalHeight(36),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          bool allSelected = ingredients
                              .every((i) => selectedIngredients[i] ?? false);
                          for (var ingredient in ingredients) {
                            selectedIngredients[ingredient] = !allSelected;
                          }
                        });
                      },
                      child: Text(
                        ingredients
                                .every((i) => selectedIngredients[i] ?? false)
                            ? "Deselect all"
                            : "Select all",
                        style: GoogleFonts.robotoFlex(
                          color: Colors.white,
                          fontSize: proportionalFontSize(14),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(proportionalWidth(12)),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: proportionalWidth(12),
                          vertical: proportionalHeight(8),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "${_getSelectedItemsCount()} Items Selected",
                    style: GoogleFonts.robotoFlex(
                      color: Colors.black54,
                      fontSize: proportionalFontSize(16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return _buildIngredientItem(
                      ingredients[index], screenWidth, screenHeight);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientItem(
      String ingredient, double screenWidth, double screenHeight) {
    bool isSelected = selectedIngredients[ingredient] ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: proportionalWidth(16),
        vertical: proportionalHeight(8),
      ),
      child: GestureDetector(
        onTap: () => _toggleIngredient(ingredient),
        child: Row(
          children: [
            Container(
              width: proportionalWidth(24),
              height: proportionalHeight(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color.fromRGBO(73, 160, 120, 1)
                    : Colors.transparent,
              ),
              child: Icon(
                isSelected ? Icons.remove : Icons.add,
                size: proportionalFontSize(16),
                color: isSelected
                    ? Colors.white
                    : const Color.fromRGBO(73, 160, 120, 1),
              ),
            ),
            SizedBox(width: proportionalWidth(12)),
            Expanded(
              child: Container(
                height: proportionalHeight(56),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(proportionalWidth(10)),
                  border: isSelected
                      ? Border.all(
                          color: const Color.fromRGBO(73, 160, 120, 1),
                          width: proportionalWidth(2),
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: proportionalWidth(16)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ingredient,
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeTabs(double screenWidth) {
    return Container(
      height: proportionalHeight(40),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: EdgeInsets.only(left: proportionalWidth(40)),
            child:
                _buildTabWithShadow(_buildRecipeTab('All', isAllSelected, () {
              setState(() {
                isAllSelected = true;
                selectedRecipe = null;
              });
            })),
          ),
          for (Recipe recipe in recipes)
            _buildTabWithShadow(
              _buildRecipeTab(recipe.name, selectedRecipe == recipe, () {
                setState(() {
                  isAllSelected = false;
                  selectedRecipe = recipe;
                });
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildTabWithShadow(Widget tab) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: proportionalWidth(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(proportionalWidth(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: proportionalWidth(2),
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: tab,
    );
  }

  Widget _buildRecipeTab(String title, bool isSelected, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color.fromRGBO(73, 160, 120, 1) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(proportionalWidth(20)),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.robotoFlex(fontSize: proportionalFontSize(14)),
      ),
    );
  }

  List<String> _getIngredientsList() {
    List<String> ingredients;
    if (isAllSelected) {
      ingredients = recipes
          .expand((recipe) =>
              _parseIngredientsQuantityInG(recipe.ingredientsQuantityInGrams))
          .toSet()
          .toList();
    } else if (selectedRecipe != null) {
      ingredients = _parseIngredientsQuantityInG(
          selectedRecipe!.ingredientsQuantityInGrams);
    } else {
      ingredients = [];
    }

    ingredients.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ingredients;
  }

  List<String> _parseIngredientsQuantityInG(String ingredientsQuantityInGrams) {
    return ingredientsQuantityInGrams
        .split('\n')
        .map((line) => line.split('->').first.trim())
        .toList();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WeeklyMenuScreen(),
              ),
            );
            break;
          default:
            break;
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/home-off.png',
            width: proportionalWidth(24),
            height: proportionalHeight(24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/discover-recipe-on.png',
            width: proportionalWidth(24),
            height: proportionalHeight(24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/grocery-list-off.png',
            width: proportionalWidth(24),
            height: proportionalHeight(24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/weekly-menu-off.png',
            width: proportionalWidth(24),
            height: proportionalHeight(24),
          ),
          label: '',
        ),
      ],
      selectedItemColor: const Color.fromRGBO(73, 160, 120, 1),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
