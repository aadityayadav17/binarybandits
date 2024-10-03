import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/recipe_selection_screen.dart';
import 'package:binarybandits/screens/profile_screen/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load recipes when the screen initializes
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    String data = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    List<dynamic> jsonResult = json.decode(data);
    List<Recipe> recipes =
        jsonResult.map((json) => Recipe.fromJson(json)).toList();
    setState(() {
      _allRecipes = recipes;
      _filteredRecipes = [];
    });
  }

  void _filterRecipes(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredRecipes = []; // Empty the list when search is cleared
      });
    } else {
      List<Recipe> filtered = _allRecipes
          .where((recipe) => recipe.name
              .toLowerCase()
              .contains(query.toLowerCase())) // Only filter by recipe name
          .toList();
      setState(() {
        _filteredRecipes = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
          elevation: 0,
          toolbarHeight: 96,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo
                  Container(
                    width: 140,
                    height: 40,
                    child: Image.asset(
                      'assets/images/app-logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Profile Icon with Background Rectangle
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          child: Image.asset(
                            'assets/icons/screens/home_screen/background-rectangle.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 28,
                          left: 28,
                          child: Container(
                            width: 32,
                            height: 32,
                            child: Image.asset(
                              'assets/icons/screens/home_screen/profile.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Main content (elements below search bar)
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, right: 30.0, top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, USER!',
                      style: GoogleFonts.robotoFlex(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      'What do you want to eat?',
                      style: GoogleFonts.robotoFlex(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromRGBO(73, 160, 120, 1),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          // Custom Search Icon from Assets
                          Image.asset(
                            'assets/icons/screens/home_screen/search-button.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search for recipe',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              onChanged: _filterRecipes,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Other UI elements like Discover Recipe Button etc.
                    _buildFeatureButton(
                      context,
                      'assets/images/home_screen/discover-recipe.png',
                      'DISCOVER\nRECIPE',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecipeSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            'assets/images/home_screen/recipe-collection.png',
                            'RECIPE\nCOLLECTION',
                            () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            'assets/images/home_screen/grocery-list.png',
                            'GROCERY\nLIST',
                            () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            'assets/images/home_screen/weekly-menu.png',
                            'WEEKLY\nMENU',
                            () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureButton(
                            context,
                            'assets/images/home_screen/recipe-history.png',
                            'HISTORY\nRECIPE',
                            () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Floating Search Results Box
            if (_filteredRecipes.isNotEmpty)
              Positioned(
                top:
                    170, // Adjust this value to position the results correctly below the search bar
                left: 30,
                right: 30,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight:
                        300, // Limit height to show max 5 items (~60px per ListTile)
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredRecipes.length > 5
                        ? 5
                        : _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              recipe.name,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text('Rating: ${recipe.rating}'),
                            onTap: () {
                              // Handle recipe selection
                            },
                          ),
                          if (index != _filteredRecipes.length - 1) Divider(),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipeSelectionScreen(),
                  ),
                );
                break;
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/bottom_navigation/home-on.png',
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

  // Helper method to build buttons with background image and text overlay
  Widget _buildFeatureButton(
    BuildContext context,
    String imagePath,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
          ),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoFlex(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const HomeScreen());
}
