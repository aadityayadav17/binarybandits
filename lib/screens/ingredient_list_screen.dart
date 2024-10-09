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
          // Recipe Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecipeTab('All', true),
                  for (Recipe recipe in recipes)
                    _buildRecipeTab(recipe.name, false),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return _buildIngredientCard(recipes[index]);
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
              child: Text(
                'Add to Grocery List',
                style: GoogleFonts.robotoFlex(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
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

  Widget _buildRecipeTab(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle tab change
        },
        child: Text(
          title,
          style: GoogleFonts.robotoFlex(),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green[400] : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  Widget _buildIngredientCard(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.green),
            onPressed: () {
              // Add single ingredient to grocery list logic
            },
          ),
          title: Text(
            recipe.ingredients, // Display the ingredients of the recipe
            style: GoogleFonts.robotoFlex(),
          ),
        ),
      ),
    );
  }
}
