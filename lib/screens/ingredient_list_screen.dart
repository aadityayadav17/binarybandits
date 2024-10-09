import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen.dart';
import 'package:binarybandits/models/recipe.dart'; // Assuming you store the Recipe model here

class IngredientListPage extends StatefulWidget {
  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  List<Recipe> recipes = [];
  Recipe? selectedRecipe; // Track the selected recipe
  bool isAllSelected = true; // To track if "All" is selected

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
    });
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
        children: [
          // Left-align the "Ingredient List" text
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ingredient List",
                style: GoogleFonts.robotoFlex(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  letterSpacing: 0,
                  height: 0.9,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recipe Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecipeTab('All', isAllSelected, () {
                    setState(() {
                      isAllSelected = true;
                      selectedRecipe = null; // Display all ingredients
                    });
                  }),
                  for (Recipe recipe in recipes)
                    _buildRecipeTab(recipe.name, selectedRecipe == recipe, () {
                      setState(() {
                        isAllSelected = false;
                        selectedRecipe = recipe; // Set the selected recipe
                      });
                    }),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          // Ingredients List
          Expanded(
            child: ListView.builder(
              itemCount: _getIngredientsList().length,
              itemBuilder: (context, index) {
                return _buildIngredientCard(_getIngredientsList()[index]);
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Add selected ingredients to grocery list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Add to Grocery List',
                style: GoogleFonts.robotoFlex(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
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
      ),
    );
  }

  // Helper method to build Recipe Tabs
  Widget _buildRecipeTab(String title, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          title,
          style: GoogleFonts.robotoFlex(),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromRGBO(73, 160, 120, 1)
              : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  // Helper method to get the list of ingredients based on the selected tab
  List<String> _getIngredientsList() {
    if (isAllSelected) {
      // Combine ingredients from all recipes by parsing "ingredients_quantity_in_g"
      return recipes
          .expand((recipe) =>
              _parseIngredientsQuantityInG(recipe.ingredientsQuantityInGrams))
          .toList();
    } else if (selectedRecipe != null) {
      // Display ingredients of the selected recipe by parsing "ingredients_quantity_in_g"
      return _parseIngredientsQuantityInG(
          selectedRecipe!.ingredientsQuantityInGrams);
    } else {
      return [];
    }
  }

  // Parse "ingredients_quantity_in_g" and extract the ingredient name (text before "->")
  List<String> _parseIngredientsQuantityInG(String ingredientsQuantityInGrams) {
    return ingredientsQuantityInGrams
        .split('\n') // Split by line breaks
        .map((line) => line
            .split('->')
            .first
            .trim()) // Extract text before "->" and trim spaces
        .toList();
  }

  // Build ingredient card
  Widget _buildIngredientCard(String ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromRGBO(73, 160, 120, 1), width: 1),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: const Color.fromRGBO(73, 160, 120, 1)),
            onPressed: () {
              // Add single ingredient to grocery list logic
            },
          ),
          title: Text(
            ingredient, // Display each ingredient
            style: GoogleFonts.robotoFlex(),
          ),
        ),
      ),
    );
  }
}
