import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/models/recipe.dart';

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
    final String response = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      recipes = data.map((json) => Recipe.fromJson(json)).toList();
      _updateAllIngredients();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10.0, bottom: 16.0),
            child: Text(
              "Ingredient List",
              style: GoogleFonts.robotoFlex(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 32,
                height: 0.9,
              ),
            ),
          ),
          _buildRecipeTabs(),
          SizedBox(height: 16),
          Expanded(
            child: _buildIngredientCard(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Add selected ingredients to grocery list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add to Grocery List',
                style: GoogleFonts.robotoFlex(
                  color: Colors.white,
                  fontSize: 16,
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

  Widget _buildIngredientCard() {
    List<String> ingredients = _getIngredientsList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 36,
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
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  Text(
                    "${_getSelectedItemsCount()} Items Selected",
                    style: GoogleFonts.robotoFlex(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  return _buildIngredientItem(ingredients[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    bool isSelected = selectedIngredients[ingredient] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () => _toggleIngredient(ingredient),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color.fromRGBO(73, 160, 120, 1)
                    : Colors.transparent,
              ),
              child: Icon(
                isSelected ? Icons.remove : Icons.add,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : const Color.fromRGBO(73, 160, 120, 1),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: const Color.fromRGBO(73, 160, 120, 1),
                          width: 2)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ingredient,
                      style: GoogleFonts.robotoFlex(fontSize: 16),
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

  Widget _buildRecipeTabs() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
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
            })),
        ],
      ),
    );
  }

  Widget _buildTabWithShadow(Widget tab) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Ensure tab background is white
        borderRadius:
            BorderRadius.circular(20), // Apply consistent border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Lighter shadow color
            spreadRadius:
                0, // No extra spread, keeping shadow tight to bottom-right
            blurRadius: 2, // Slight blur for softness
            offset: Offset(2, 2), // Shift shadow towards bottom-right
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.robotoFlex(fontSize: 14),
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

    // Sort the ingredients alphabetically
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
      selectedItemColor: const Color.fromRGBO(73, 160, 120, 1),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
