import 'dart:convert';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/recipe_collection_screen/recipe_collection_detail_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Proportional helper functions
double proportionalWidth(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

double proportionalHeight(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.height / 812;
}

double proportionalFontSize(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 375;
}

class RecipeCollectionPage extends StatefulWidget {
  const RecipeCollectionPage({super.key});

  @override
  _RecipeCollectionPageState createState() => _RecipeCollectionPageState();
}

class _RecipeCollectionPageState extends State<RecipeCollectionPage> {
  List<Recipe> savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeCollection');

      // Fetch saved recipes from Firebase
      DataSnapshot snapshot =
          await userRef.once().then((event) => event.snapshot);

      if (snapshot.value != null) {
        Map<dynamic, dynamic> recipeMap =
            snapshot.value as Map<dynamic, dynamic>;

        // Filter out recipes that have `saved == true`
        List<dynamic> savedRecipeEntries = recipeMap.values
            .where((recipe) => recipe['saved'] == true)
            .toList();

        // Load the full recipe details from the JSON and filter by saved IDs
        final String response = await rootBundle
            .loadString('assets/recipes/D3801 Recipes - Recipes.json');
        final List<dynamic> data = json.decode(response);

        List<Recipe> allRecipes =
            data.map((json) => Recipe.fromJson(json)).toList();

        // Filter the recipes that are saved
        setState(() {
          savedRecipes = allRecipes
              .where((recipe) =>
                  savedRecipeEntries.any((entry) => entry['id'] == recipe.id))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: proportionalHeight(context, 60),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: proportionalWidth(context, 8)),
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/common/back-key.png',
              width: proportionalWidth(context, 24),
              height: proportionalHeight(context, 24),
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
              left: proportionalWidth(context, 16),
              top: proportionalHeight(context, 10),
              bottom: proportionalHeight(context, 16),
            ),
            child: Text(
              "Saved Recipes",
              style: GoogleFonts.robotoFlex(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: proportionalFontSize(context, 32),
                height: 0.9,
              ),
            ),
          ),
          Expanded(
            child: _buildRecipeList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildRecipeList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: proportionalWidth(context, 16)),
      itemCount: savedRecipes.length,
      itemBuilder: (context, index) {
        return _buildRecipeItem(savedRecipes[index]);
      },
    );
  }

  Widget _buildRecipeItem(Recipe recipe) {
    return Padding(
      padding: EdgeInsets.only(
        left: proportionalWidth(context, 16),
        right: proportionalWidth(context, 16),
        bottom: proportionalHeight(context, 16),
      ),
      child: GestureDetector(
        onTap: () {
          // Navigate to the new recipe collection detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RecipeCollectionDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Container(
          height: proportionalHeight(context, 56),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(proportionalWidth(context, 10)),
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
            padding: EdgeInsets.symmetric(
                horizontal: proportionalWidth(context, 16)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                recipe.name,
                style: GoogleFonts.robotoFlex(
                  fontSize: proportionalFontSize(context, 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 1, // Assuming this is the second tab
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeSelectionScreen(),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroceryListScreen(),
              ),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WeeklyMenuScreen(),
              ),
            );
            break;
        }
      },
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/home-off.png',
            width: proportionalWidth(context, 24),
            height: proportionalHeight(context, 24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/discover-recipe-off.png',
            width: proportionalWidth(context, 22),
            height: proportionalHeight(context, 22),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/grocery-list-off.png',
            width: proportionalWidth(context, 24),
            height: proportionalHeight(context, 24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/weekly-menu-off.png',
            width: proportionalWidth(context, 24),
            height: proportionalHeight(context, 24),
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
