import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_overview_screen/recipe_overview_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_card_components.dart';
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

class RecipeSelectionScreen extends StatefulWidget {
  const RecipeSelectionScreen({super.key});

  @override
  _RecipeSelectionScreenState createState() => _RecipeSelectionScreenState();
}

class _RecipeSelectionScreenState extends State<RecipeSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Recipe> _recipes = [];
  int _currentRecipeIndex = 0;
  List<bool> _savedRecipes = [];
  int _selectedCount = 0; // This now reflects the accepted recipes count
  final ScrollController _scrollController = ScrollController();
  List<int> _recipeHistory = [];
  List<bool> _acceptedRecipes = [];

  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late double _dragStartX;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_swipeController);
  }

  Future<void> _loadRecipes() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Load the recipe JSON from local assets
    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    List<Recipe> allRecipes =
        jsonData.map((data) => Recipe.fromJson(data)).toList();

    if (user != null) {
      // Reference to the user's recipeHistory in Firebase
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');

      // Fetch accepted recipes from Firebase
      DataSnapshot snapshot =
          await userRef.once().then((event) => event.snapshot);

      // If there are accepted recipes, filter them out
      List<String> acceptedRecipeIds = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> recipeMap =
            snapshot.value as Map<dynamic, dynamic>;
        acceptedRecipeIds = recipeMap.values
            .where((recipe) => recipe['accepted'] == true)
            .map<String>((recipe) => recipe['id'].toString())
            .toList();

        // Update the selected count to reflect the number of accepted recipes
        setState(() {
          _selectedCount = acceptedRecipeIds.length;
        });
      }

      // Filter out recipes that have been accepted
      List<Recipe> remainingRecipes = allRecipes
          .where((recipe) => !acceptedRecipeIds.contains(recipe.id))
          .toList();

      // Check if no recipes are left, then redirect
      if (remainingRecipes.isEmpty) {
        Navigator.pushReplacementNamed(context, '/no_recipe_selection_screen');
      } else {
        // Load remaining recipes
        setState(() {
          _recipes = remainingRecipes;
          _savedRecipes = List.generate(_recipes.length, (_) => false);
          _acceptedRecipes = List.generate(_recipes.length, (_) => false);
        });
      }
    } else {
      // If the user is not logged in or there is an error, load all recipes
      setState(() {
        _recipes = allRecipes;
        _savedRecipes = List.generate(_recipes.length, (_) => false);
        _acceptedRecipes = List.generate(_recipes.length, (_) => false);
      });
    }
  }

  void _nextRecipe({bool accepted = false}) {
    setState(() {
      _acceptedRecipes[_currentRecipeIndex] = accepted;
      _recipeHistory.add(_currentRecipeIndex);

      // Move to the next recipe, but skip over accepted ones
      do {
        _currentRecipeIndex = (_currentRecipeIndex + 1) % _recipes.length;
      } while (_acceptedRecipes[_currentRecipeIndex] &&
          _recipeHistory.length < _recipes.length);

      _scrollController.jumpTo(0);
    });

    // Check if all recipes are accepted after moving to the next one
    _checkAllRecipesAccepted();
  }

  void _checkAllRecipesAccepted() {
    if (_acceptedRecipes.every((isAccepted) => isAccepted)) {
      // Redirect if all recipes are accepted
      Navigator.pushReplacementNamed(context, '/no_recipe_selection_screen');
    }
  }

  void _acceptRecipe() {
    // Save the current recipe before moving to the next
    _swipeController.forward().then((_) async {
      // Ensure the recipe is saved before moving forward
      await _saveRecipeToFirebase(_recipes[_currentRecipeIndex],
          accepted: true);

      setState(() {
        _selectedCount++; // Increment the counter when a recipe is accepted
        _nextRecipe(accepted: true); // Move to the next recipe after saving
        _resetSwipe();
      });
    });
  }

  void _rejectRecipe() {
    // Save the current recipe before moving to the next
    _swipeController.forward().then((_) async {
      // Ensure the recipe is saved before moving forward
      await _saveRecipeToFirebase(_recipes[_currentRecipeIndex],
          accepted: false);

      setState(() {
        _nextRecipe(accepted: false); // Move to the next recipe after saving
        _resetSwipe();
      });
    });
  }

  Future<void> _saveRecipeToFirebase(Recipe recipe,
      {required bool accepted}) async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Prepare a reference to the user's recipe collection in the database
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');

      // Create a Map for the recipe data to store
      Map<String, dynamic> recipeData = {
        'id': recipe.id, // Save the recipe ID
        'name': recipe.name, // Save the recipe name
        'accepted': accepted, // true if accepted, false if rejected
      };

      // Push the recipe data to Firebase
      await userRef.push().set(recipeData);
    }
  }

  void _undoRecipe() {
    if (_recipeHistory.isNotEmpty) {
      setState(() {
        int previousIndex = _recipeHistory.removeLast();
        _currentRecipeIndex = previousIndex;
        _scrollController.jumpTo(0);

        // Check if the previous recipe was accepted and update the count
        if (_acceptedRecipes[previousIndex]) {
          _selectedCount--;
          _acceptedRecipes[previousIndex] = false;
        }

        // Update Firebase to remove the previous decision
        _updateRecipeInFirebase(_recipes[previousIndex], accepted: null);
      });
    }
  }

  Future<void> _updateRecipeInFirebase(Recipe recipe, {bool? accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');

      // Query to find the existing entry for this recipe
      Query query = userRef.orderByChild('id').equalTo(recipe.id);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null) {
        // If the recipe exists, update it
        Map<dynamic, dynamic> recipeMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        String key = recipeMap.keys.first;
        if (accepted == null) {
          // If accepted is null, remove the entry
          await userRef.child(key).remove();
        } else {
          // Update the accepted status
          await userRef.child(key).update({'accepted': accepted});
        }
      } else if (accepted != null) {
        // If the recipe doesn't exist and we have a decision, add it
        Map<String, dynamic> recipeData = {
          'id': recipe.id,
          'name': recipe.name,
          'accepted': accepted,
        };
        await userRef.push().set(recipeData);
      }
    }
  }

  void _resetSwipe() {
    _swipeController.reverse();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_recipes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final recipe = _recipes[_currentRecipeIndex];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
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
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight - proportionalHeight(context, 60),
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: proportionalWidth(context, 16)),
                      child: Column(
                        children: [
                          SizedBox(height: proportionalHeight(context, 1)),
                          Row(
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
                                      fontSize: proportionalFontSize(context,
                                          32), // Proportional font size
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
                                    '$_selectedCount',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: proportionalFontSize(context,
                                          32), // Proportional font size
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "Selected",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: proportionalFontSize(context,
                                          16), // Proportional font size
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: proportionalHeight(context, 16)),
                        ],
                      ),
                    ),
                    RecipeCardStack(
                      recipe: recipe,
                      isSaved: _savedRecipes[_currentRecipeIndex],
                      onSave: () {
                        setState(() {
                          _savedRecipes[_currentRecipeIndex] =
                              !_savedRecipes[_currentRecipeIndex];
                        });
                      },
                      onUndo: _undoRecipe,
                      screenWidth: screenWidth,
                      cardTopPosition: proportionalHeight(context, 280),
                      cardHeight: proportionalHeight(context, 196),
                      scrollController: _scrollController,
                    ),
                  ],
                ),
                RecipeInformationCard(
                  key: ValueKey(recipe.id),
                  recipe: recipe,
                  topPosition: proportionalHeight(
                      context, 310), // Adjusted proportionally
                  cardHeight: proportionalHeight(context, 196),
                  scrollController: _scrollController,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight, // Added screenHeight argument
                ),
                Positioned(
                  // Position the action buttons (including Done) below the RecipeInformationCard
                  top: proportionalHeight(context, 530),
                  // Adjust 'top' to be below the recipe information card
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                        'assets/icons/screens/recipe_selection_screen/recipe-rejected.png',
                        _rejectRecipe,
                        screenWidth, // Pass screen width for proportional size
                      ),
                      SizedBox(width: proportionalWidth(context, 16)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const RecipeOverviewScreen(),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(73, 160, 120, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                proportionalWidth(context, 10)),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: proportionalWidth(context, 70),
                            vertical: proportionalHeight(context, 12),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: proportionalFontSize(context, 16),
                          ),
                        ),
                      ),
                      SizedBox(width: proportionalWidth(context, 16)),
                      _buildActionButton(
                        'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                        'assets/icons/screens/recipe_selection_screen/recipe-accepted.png',
                        _acceptRecipe,
                        screenWidth, // Pass screen width for proportional size
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildActionButton(String backgroundPath, String iconPath,
      VoidCallback onPressed, double screenWidth) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(proportionalWidth(context, 10))),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
      ),
      child: Stack(
        children: [
          Image.asset(backgroundPath,
              width: proportionalWidth(context, 62),
              height: proportionalHeight(context, 62)),
          Positioned(
            top: proportionalHeight(context, 18),
            left: proportionalWidth(context, 18),
            child: Image.asset(iconPath,
                width: proportionalWidth(context, 20),
                height: proportionalHeight(context, 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
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
            // Action for Discover Recipe button
            break;
          case 2:
            // Action for Grocery List button
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
            width: proportionalWidth(context, 24),
            height: proportionalHeight(context, 24),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/discover-recipe-on.png',
            width: proportionalWidth(context, 24),
            height: proportionalHeight(context, 24),
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
