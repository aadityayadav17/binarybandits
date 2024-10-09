import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen.dart';
import 'package:binarybandits/models/recipe.dart';

class IngredientListPage extends StatefulWidget {
  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage> {
  List<Recipe> recipes = [];
  Recipe? selectedRecipe;
  bool isAllSelected = true;
  int selectedCount = 0;

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
                  borderRadius: BorderRadius.circular(25),
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
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add all ingredients logic
                    },
                    icon: Icon(Icons.add, color: Colors.white, size: 18),
                    label: Text(
                      "Add all",
                      style: GoogleFonts.robotoFlex(
                          color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  Text(
                    "${ingredients.length} Items",
                    style: GoogleFonts.robotoFlex(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade300),
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
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
            Icons.add_circle_outline,
            color: const Color.fromRGBO(73, 160, 120, 1),
          ),
          title: Text(
            ingredient,
            style: GoogleFonts.robotoFlex(fontSize: 16),
          ),
          onTap: () {
            // Add single ingredient to grocery list logic
          },
        ),
        Divider(height: 1, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildRecipeTabs() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 16),
          _buildRecipeTab('All', isAllSelected, () {
            setState(() {
              isAllSelected = true;
              selectedRecipe = null;
            });
          }),
          for (Recipe recipe in recipes)
            _buildRecipeTab(recipe.name, selectedRecipe == recipe, () {
              setState(() {
                isAllSelected = false;
                selectedRecipe = recipe;
              });
            }),
        ],
      ),
    );
  }

  Widget _buildRecipeTab(String title, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          title,
          style: GoogleFonts.robotoFlex(fontSize: 14),
        ),
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
      ),
    );
  }

  List<String> _getIngredientsList() {
    if (isAllSelected) {
      return recipes
          .expand((recipe) =>
              _parseIngredientsQuantityInG(recipe.ingredientsQuantityInGrams))
          .toList();
    } else if (selectedRecipe != null) {
      return _parseIngredientsQuantityInG(
          selectedRecipe!.ingredientsQuantityInGrams);
    } else {
      return [];
    }
  }

  List<String> _parseIngredientsQuantityInG(String ingredientsQuantityInGrams) {
    return ingredientsQuantityInGrams
        .split('\n')
        .map((line) => line.split('->').first.trim())
        .toList();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      onTap: (index) {
        // Navigation logic
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
