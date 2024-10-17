import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/profile_screen/profile.dart';
import 'package:binarybandits/screens/recipe_collection_screen/recipe_collection_screen.dart';
import 'package:binarybandits/screens/recipe_history_screen/recipe_history.dart';
import 'package:binarybandits/screens/home_screen/recipe_search_detail_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _allRecipes = [];
  List<Recipe> _filteredRecipes = [];
  final FocusNode _searchFocusNode = FocusNode();
  String userName = "User"; // Default value // Create a FocusNode

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _fetchUserName(); // Fetch user's name from Firebase
  }

  Future<void> _fetchUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Reference to the user's data in Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$uid");

      // Listen for data once
      userRef.once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          setState(() {
            userName = event.snapshot.child("name").value as String;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
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
        _filteredRecipes = [];
      });
    } else {
      List<Recipe> filtered = _allRecipes
          .where((recipe) =>
              recipe.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      setState(() {
        _filteredRecipes = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Proportional sizing functions
    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
    double proportionalWidth(double size) => size * screenWidth / 375;

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() {
            _filteredRecipes = [];
          });
        },
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
          appBar: AppBar(
            backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
            elevation: 0,
            toolbarHeight: proportionalHeight(96),
            flexibleSpace: SafeArea(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: proportionalWidth(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // App Logo
                    SizedBox(
                      width: proportionalWidth(140),
                      height: proportionalHeight(40),
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
                            builder: (context) =>
                                const ProfileScreen(fromSignup: false),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: proportionalWidth(96),
                            height: proportionalHeight(96),
                            child: Image.asset(
                              'assets/icons/screens/home_screen/background-rectangle.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: proportionalHeight(28),
                            left: proportionalWidth(28),
                            child: SizedBox(
                              width: proportionalWidth(32),
                              height: proportionalHeight(32),
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
              SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: proportionalWidth(30)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: proportionalHeight(16)),
                      Text(
                        'Hello, $userName!',
                        style: GoogleFonts.robotoFlex(
                          fontSize: proportionalFontSize(32),
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'What do you want to eat?',
                        style: GoogleFonts.robotoFlex(
                          fontSize: proportionalFontSize(20),
                          fontWeight: FontWeight.w900,
                          color: const Color.fromRGBO(73, 160, 120, 1),
                        ),
                      ),
                      SizedBox(height: proportionalHeight(16)),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(proportionalWidth(30)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: proportionalWidth(16),
                          vertical: proportionalHeight(4),
                        ),
                        child: Row(
                          children: [
                            // Custom Search Icon from Assets
                            Image.asset(
                              'assets/icons/screens/home_screen/search-button.png',
                              width: proportionalWidth(24),
                              height: proportionalHeight(24),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: proportionalWidth(8)),
                            Expanded(
                              child: TextField(
                                focusNode: _searchFocusNode,
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
                      SizedBox(height: proportionalHeight(16)),
                      // Other UI elements like Discover Recipe Button etc.
                      _buildFeatureButton(
                        context,
                        'assets/images/home_screen/discover-recipe.png',
                        'CREATE\nMEAL PLAN',
                        proportionalHeight(160),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RecipeSelectionScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: proportionalHeight(16)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureButton(
                              context,
                              'assets/images/home_screen/weekly-menu.png',
                              'MY MEAL\nPLAN',
                              proportionalHeight(110),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WeeklyMenuScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: proportionalWidth(16)),
                          Expanded(
                            child: _buildFeatureButton(
                              context,
                              'assets/images/home_screen/grocery-list.png',
                              'GROCERY\nLIST',
                              proportionalHeight(110),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroceryListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: proportionalHeight(16)),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeatureButton(
                              context,
                              'assets/images/home_screen/recipe-collection.png',
                              'SAVED\nRECIPES',
                              proportionalHeight(110),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeCollectionPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: proportionalWidth(16)),
                          Expanded(
                            child: _buildFeatureButton(
                              context,
                              'assets/images/home_screen/recipe-history.png',
                              'RECIPE\nHISTORY',
                              proportionalHeight(110),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeHistoryPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_filteredRecipes.isNotEmpty)
                Positioned(
                  top: proportionalHeight(170),
                  left: proportionalWidth(30),
                  right: proportionalWidth(30),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: proportionalHeight(300),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(proportionalWidth(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: proportionalWidth(1),
                          blurRadius: proportionalWidth(5),
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
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      recipe.name,
                                      style: GoogleFonts.roboto(
                                        fontSize: proportionalFontSize(16),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/screens/recipe_selection_screen/rating.png',
                                        width: proportionalWidth(14),
                                        height: proportionalHeight(14),
                                      ),
                                      SizedBox(width: proportionalWidth(4)),
                                      Text(
                                        recipe.rating.toStringAsFixed(1),
                                        style: GoogleFonts.roboto(
                                          fontSize: proportionalFontSize(14),
                                          color: const Color.fromRGBO(
                                              73, 160, 120, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeSearchDetailScreen(
                                            recipe: recipe),
                                  ),
                                );
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
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String imagePath,
    String text,
    double height,
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
              height: height,
            ),
          ),
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 144, 186, 168).withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoFlex(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 254, 254),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 1,
      onTap: (index) {
        switch (index) {
          case 0:
            // Action for Home button
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
            'assets/icons/bottom_navigation/home-on.png',
            width: 26,
            height: 26,
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/discover-recipe-off.png',
            width: 22,
            height: 22,
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
