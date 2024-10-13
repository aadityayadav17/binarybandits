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
  List<bool> _acceptedRecipes = [];
  int _selectedCount = 0;
  final ScrollController _scrollController = ScrollController();
  List<int> _recipeHistory = [];

  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;

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
    User? user = FirebaseAuth.instance.currentUser;

    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    List<Recipe> allRecipes =
        jsonData.map((data) => Recipe.fromJson(data)).toList();

    if (user != null) {
      DatabaseReference historyRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');
      DatabaseReference collectionRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeCollection');

      DataSnapshot historySnapshot =
          await historyRef.once().then((event) => event.snapshot);
      DataSnapshot collectionSnapshot =
          await collectionRef.once().then((event) => event.snapshot);

      Set<String> acceptedRecipeIds = {};
      Set<String> savedRecipeIds = {};

      if (historySnapshot.value != null) {
        Map<dynamic, dynamic> historyMap =
            historySnapshot.value as Map<dynamic, dynamic>;
        acceptedRecipeIds = historyMap.values
            .where((recipe) => recipe['accepted'] == true)
            .map<String>((recipe) => recipe['id'].toString())
            .toSet();
      }

      if (collectionSnapshot.value != null) {
        Map<dynamic, dynamic> collectionMap =
            collectionSnapshot.value as Map<dynamic, dynamic>;
        savedRecipeIds = collectionMap.values
            .where((recipe) => recipe['saved'] == true)
            .map<String>((recipe) => recipe['id'].toString())
            .toSet();
      }

      List<Recipe> remainingRecipes = allRecipes
          .where((recipe) => !acceptedRecipeIds.contains(recipe.id))
          .toList();

      if (remainingRecipes.isEmpty) {
        Navigator.pushReplacementNamed(context, '/no_recipe_selection_screen');
      } else {
        setState(() {
          _recipes = remainingRecipes;
          _savedRecipes = remainingRecipes
              .map((recipe) => savedRecipeIds.contains(recipe.id))
              .toList();
          _acceptedRecipes =
              List.generate(remainingRecipes.length, (_) => false);
          _selectedCount = acceptedRecipeIds.length;
        });
      }
    } else {
      setState(() {
        _recipes = allRecipes;
        _savedRecipes = List.generate(allRecipes.length, (_) => false);
        _acceptedRecipes = List.generate(allRecipes.length, (_) => false);
      });
    }
  }

  Future<void> _acceptRecipe() async {
    try {
      await _addRecipeToHistory(_recipes[_currentRecipeIndex], accepted: true);

      setState(() {
        _acceptedRecipes[_currentRecipeIndex] = true;
        _selectedCount++;
        _recipeHistory.add(_currentRecipeIndex);
        _nextRecipe();
      });
    } catch (e) {
      _showErrorDialog("Error accepting recipe: $e");
    }
  }

  Future<void> _rejectRecipe() async {
    try {
      await _addRecipeToHistory(_recipes[_currentRecipeIndex], accepted: false);

      setState(() {
        _acceptedRecipes[_currentRecipeIndex] = false;
        _recipeHistory.add(_currentRecipeIndex);
        _nextRecipe();
      });
    } catch (e) {
      _showErrorDialog("Error rejecting recipe: $e");
    }
  }

  void _nextRecipe() {
    int nextIndex = (_currentRecipeIndex + 1) % _recipes.length;
    while (_acceptedRecipes[nextIndex] &&
        _recipeHistory.length < _recipes.length) {
      nextIndex = (nextIndex + 1) % _recipes.length;
    }
    _currentRecipeIndex = nextIndex;
    _scrollController.jumpTo(0);
    _checkAllRecipesAccepted();
  }

  void _checkAllRecipesAccepted() {
    if (_acceptedRecipes.every((isAccepted) => isAccepted)) {
      Navigator.pushReplacementNamed(context, '/no_recipe_selection_screen');
    }
  }

  Future<void> _onSaveRecipe() async {
    try {
      bool newSavedState = !_savedRecipes[_currentRecipeIndex];
      await _updateRecipeInCollection(_recipes[_currentRecipeIndex],
          saved: newSavedState);

      setState(() {
        _savedRecipes[_currentRecipeIndex] = newSavedState;
      });
    } catch (e) {
      _showErrorDialog("Error saving recipe: $e");
    }
  }

  Future<void> _saveRecipeToFirebase(Recipe recipe,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference historyRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');

      // Check if the recipe already exists in the history
      Query query = historyRef.orderByChild('id').equalTo(recipe.id);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null) {
        // Recipe exists, update it
        Map<dynamic, dynamic> recipeMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        String key = recipeMap.keys.first;
        await historyRef.child(key).update({
          'accepted': accepted,
          'timestamp': ServerValue.timestamp,
        });
      } else {
        // Recipe doesn't exist, create a new entry
        Map<String, dynamic> recipeData = {
          'id': recipe.id,
          'name': recipe.name,
          'accepted': accepted,
          'timestamp': ServerValue.timestamp,
        };
        await historyRef.push().set(recipeData);
      }
    }
  }

  Future<void> _updateRecipeInCollection(Recipe recipe,
      {required bool saved}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference collectionRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeCollection');

      // Check if the recipe already exists in the collection
      Query query = collectionRef.orderByChild('id').equalTo(recipe.id);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null) {
        // Recipe exists, update it
        Map<dynamic, dynamic> recipeMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        String key = recipeMap.keys.first;
        if (saved) {
          await collectionRef.child(key).update({
            'saved': true,
            'name': recipe.name,
            'timestamp': ServerValue.timestamp,
          });
        } else {
          // If unsaving, remove the entry
          await collectionRef.child(key).remove();
        }
      } else if (saved) {
        // Recipe doesn't exist and we're saving it, create a new entry
        Map<String, dynamic> recipeData = {
          'id': recipe.id,
          'name': recipe.name,
          'saved': true,
          'timestamp': ServerValue.timestamp,
        };
        await collectionRef.push().set(recipeData);
      }
    }
  }

  Future<void> _undoRecipe() async {
    if (_recipeHistory.isNotEmpty) {
      try {
        int previousIndex = _recipeHistory.removeLast();
        Recipe recipeToUndo = _recipes[previousIndex];

        // Remove the recipe from Firebase history
        await _removeRecipeFromHistory(recipeToUndo);

        setState(() {
          _currentRecipeIndex = previousIndex;
          if (_acceptedRecipes[previousIndex]) {
            _selectedCount--;
          }
          _acceptedRecipes[previousIndex] = false;
        });
      } catch (e) {
        _showErrorDialog("Error undoing action: $e");
      }
    }
  }

  Future<void> _removeRecipeFromHistory(Recipe recipe) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference historyRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');

      // Find and remove the recipe entry
      Query query = historyRef.orderByChild('id').equalTo(recipe.id);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> recipeMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        String key = recipeMap.keys.first;
        await historyRef.child(key).remove();
      }
    }
  }

  Future<void> _addRecipeToHistory(Recipe recipe,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference historyRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeHistory');

      Map<String, dynamic> recipeData = {
        'id': recipe.id,
        'name': recipe.name,
        'accepted': accepted,
        'timestamp': ServerValue.timestamp,
      };

      await historyRef.push().set(recipeData);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  // The build method and other UI-related methods remain largely unchanged
  // but should be updated to use the new state variables and methods

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
                    Stack(
                      children: [
                        RecipeCardStack(
                          recipe: recipe,
                          screenWidth: screenWidth,
                          cardTopPosition: proportionalHeight(context, 280),
                          cardHeight: proportionalHeight(context, 196),
                          scrollController: _scrollController,
                        ),
                        Positioned(
                          top: 20,
                          left: screenWidth * 0.05,
                          child: IconButton(
                            icon: Image.asset(
                              'assets/icons/screens/recipe_selection_screen/undo.png',
                              width: proportionalWidth(context, 20),
                              height: proportionalHeight(context, 20),
                            ),
                            onPressed: _undoRecipe,
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: screenWidth * 0.05,
                          child: IconButton(
                            icon: Image.asset(
                              _savedRecipes[_currentRecipeIndex]
                                  ? 'assets/icons/screens/recipe_selection_screen/save-on.png'
                                  : 'assets/icons/screens/recipe_selection_screen/save.png',
                              width: proportionalWidth(context, 20),
                              height: proportionalHeight(context, 20),
                            ),
                            onPressed: _onSaveRecipe,
                          ),
                        ),
                      ],
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
