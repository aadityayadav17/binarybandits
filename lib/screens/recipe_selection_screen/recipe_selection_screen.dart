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
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
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
  Map<String, dynamic> _recipeWeeklyMenu = {};
  Map<String, String> _recipeWeeklyMenuKeys = {};
  Map<String, dynamic> _recipeHistory = {};
  Map<String, String> _recipeHistoryKeys = {};
  Map<String, dynamic> _recipeCollection = {};
  Map<String, String> _recipeCollectionKeys = {};

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

    // Load all recipes from JSON
    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    List<Recipe> allRecipes =
        jsonData.map((data) => Recipe.fromJson(data)).toList();

    if (user != null) {
      await _loadDatabaseRecipes(user, 'recipeWeeklyMenu');
      await _loadDatabaseRecipes(user, 'recipeHistory');
      await _loadRecipeCollection(user);

      // Load PossibleRecipes from Firebase
      DatabaseReference possibleRecipesRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('PossibleRecipes');

      DataSnapshot snapshot =
          await possibleRecipesRef.once().then((event) => event.snapshot);

      Set<String> possibleRecipeIds = {};

      if (snapshot.value != null) {
        List<dynamic> possibleRecipes = snapshot.value as List<dynamic>;
        possibleRecipeIds = possibleRecipes
            .map<String>((recipe) => recipe['recipe_id'].toString())
            .toSet();
      }

      // Filter allRecipes to only include those present in PossibleRecipes
      setState(() {
        _recipes = allRecipes
            .where((recipe) =>
                possibleRecipeIds.contains(recipe.id) &&
                (!_recipeWeeklyMenu.containsKey(recipe.id) ||
                    _recipeWeeklyMenu[recipe.id]['accepted'] == false))
            .toList();
        _acceptedRecipes = List.generate(_recipes.length, (index) => false);
        _savedRecipes = List.generate(
            _recipes.length,
            (index) =>
                _recipeCollection.containsKey(_recipes[index].id) &&
                _recipeCollection[_recipes[index].id]['saved'] == true);
        _selectedCount = _recipeWeeklyMenu.values
            .where((recipe) => recipe['accepted'] == true)
            .length;
      });
    } else {
      setState(() {
        _recipes = allRecipes;
        _acceptedRecipes = List.generate(_recipes.length, (_) => false);
        _savedRecipes = List.generate(_recipes.length, (_) => false);
      });
    }

    if (_recipes.isEmpty) {
      Navigator.pushReplacementNamed(context, '/no_recipe_selection_screen');
    }
  }

  Future<void> _loadDatabaseRecipes(User user, String databaseName) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child(databaseName);

    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

    if (snapshot.value != null) {
      Map<dynamic, dynamic> recipeMap = snapshot.value as Map<dynamic, dynamic>;
      Map<String, dynamic> processedMap = {};

      recipeMap.forEach((key, value) {
        String recipeId = value['id'].toString();
        processedMap[recipeId] = {
          'key': key,
          'name': value['name'],
          'accepted': value['accepted'],
          'timestamp': value['timestamp'],
          'servings': value['servings'] ?? 1,
        };
      });

      if (databaseName == 'recipeWeeklyMenu') {
        _recipeWeeklyMenu = processedMap;
      } else {
        _recipeHistory = processedMap;
      }
    }
  }

  Future<void> _loadRecipeCollection(User user) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('recipeCollection');

    DataSnapshot snapshot = await ref.once().then((event) => event.snapshot);

    if (snapshot.value != null) {
      Map<dynamic, dynamic> collectionMap =
          snapshot.value as Map<dynamic, dynamic>;
      Map<String, dynamic> processedMap = {};

      collectionMap.forEach((key, value) {
        String recipeId = value['id'].toString();
        processedMap[recipeId] = {
          'key': key,
          'name': value['name'],
          'saved': value['saved'] ?? false,
          'timestamp': value['timestamp'],
        };
      });

      _recipeCollection = processedMap;
    }
  }

  Future<void> _updateRecipeInDatabase(
      String databaseName, Recipe recipe, bool accepted) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child(databaseName);

      Map<String, dynamic> targetMap = databaseName == 'recipeWeeklyMenu'
          ? _recipeWeeklyMenu
          : _recipeHistory;

      if (targetMap.containsKey(recipe.id)) {
        // Update existing entry
        await ref.child(targetMap[recipe.id]['key']).update({
          'accepted': accepted,
          'timestamp': ServerValue.timestamp,
        });
        if (databaseName == 'recipeWeeklyMenu' &&
            !targetMap[recipe.id].containsKey('servings')) {
          await ref.child(targetMap[recipe.id]['key']).update({'servings': 1});
        }
      } else {
        // Create new entry
        DatabaseReference newRef = ref.push();
        Map<String, dynamic> newEntry = {
          'id': recipe.id,
          'name': recipe.name,
          'accepted': accepted,
          'timestamp': ServerValue.timestamp,
        };
        if (databaseName == 'recipeWeeklyMenu') {
          newEntry['servings'] = 1;
        }
        await newRef.set(newEntry);
        targetMap[recipe.id] = {
          'key': newRef.key,
          'name': recipe.name,
          'accepted': accepted,
          'timestamp': ServerValue.timestamp,
        };
        if (databaseName == 'recipeWeeklyMenu') {
          targetMap[recipe.id]['servings'] = 1;
        }
      }

      // Update local state
      setState(() {
        if (databaseName == 'recipeWeeklyMenu') {
          _recipeWeeklyMenu = Map.from(targetMap);
        } else {
          _recipeHistory = Map.from(targetMap);
        }
      });
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

      String? newRefKey;

      if (_recipeCollection.containsKey(recipe.id)) {
        // Update existing entry
        await collectionRef.child(_recipeCollection[recipe.id]['key']).update({
          'saved': saved,
          'timestamp': ServerValue.timestamp,
        });
      } else if (saved) {
        // Create new entry only if saving
        DatabaseReference newRef = collectionRef.push();
        newRefKey = newRef.key;
        await newRef.set({
          'id': recipe.id,
          'name': recipe.name,
          'saved': true,
          'timestamp': ServerValue.timestamp,
        });
      }

      // Update local state
      setState(() {
        if (!saved) {
          _recipeCollection[recipe.id]?['saved'] = false;
        } else {
          _recipeCollection[recipe.id] = {
            'key': _recipeCollection[recipe.id]?['key'] ?? newRefKey,
            'name': recipe.name,
            'saved': true,
            'timestamp': ServerValue.timestamp,
          };
        }
        _savedRecipes[_currentRecipeIndex] = saved;
      });
    }
  }

  Future<void> _loadSavedRecipes() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference collectionRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeCollection');

      DataSnapshot collectionSnapshot =
          await collectionRef.once().then((event) => event.snapshot);

      if (collectionSnapshot.value != null) {
        Map<dynamic, dynamic> collectionMap =
            collectionSnapshot.value as Map<dynamic, dynamic>;
        Set<String> savedRecipeIds = collectionMap.values
            .where((recipe) => recipe['saved'] == true)
            .map<String>((recipe) => recipe['id'].toString())
            .toSet();

        setState(() {
          for (int i = 0; i < _recipes.length; i++) {
            _savedRecipes[i] = savedRecipeIds.contains(_recipes[i].id);
          }
        });
      }
    }
  }

  Future<void> _loadWeeklyMenu(User user) async {
    DatabaseReference weeklyMenuRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('recipeWeeklyMenu');

    DataSnapshot weeklyMenuSnapshot =
        await weeklyMenuRef.once().then((event) => event.snapshot);

    if (weeklyMenuSnapshot.value != null) {
      Map<dynamic, dynamic> weeklyMenuMap =
          weeklyMenuSnapshot.value as Map<dynamic, dynamic>;

      _recipeWeeklyMenuKeys.clear();
      Set<String> acceptedRecipeIds = {};

      weeklyMenuMap.forEach((key, value) {
        String recipeId = value['id'].toString();
        _recipeWeeklyMenuKeys[recipeId] = key;
        if (value['accepted'] == true) {
          acceptedRecipeIds.add(recipeId);
        }
      });

      setState(() {
        _recipes = _recipes
            .where((recipe) => !acceptedRecipeIds.contains(recipe.id))
            .toList();
        _acceptedRecipes = List.generate(_recipes.length, (index) => false);
        _savedRecipes = List.generate(_recipes.length, (index) => false);
        _selectedCount = acceptedRecipeIds.length;
      });
    }
  }

  Future<void> _loadRecipeHistory(User user) async {
    DatabaseReference historyRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('recipeHistory');

    DataSnapshot historySnapshot =
        await historyRef.once().then((event) => event.snapshot);

    if (historySnapshot.value != null) {
      Map<dynamic, dynamic> historyMap =
          historySnapshot.value as Map<dynamic, dynamic>;

      _recipeHistoryKeys.clear();

      historyMap.forEach((key, value) {
        String recipeId = value['id'].toString();
        _recipeHistoryKeys[recipeId] = key;
      });
    }
  }

  Future<void> _updateRecipeWeeklyMenu(Recipe recipe,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _updateRecipeInDatabase('recipeWeeklyMenu', recipe, accepted);
    }
  }

  Future<void> _updateRecipeHistory(Recipe recipe,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _updateRecipeInDatabase('recipeHistory', recipe, accepted);
    }
  }

  Future<void> _updateServings(String recipeId, int newServings) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _recipeWeeklyMenu.containsKey(recipeId)) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu')
          .child(_recipeWeeklyMenu[recipeId]['key']);

      await ref.update({'servings': newServings});

      setState(() {
        _recipeWeeklyMenu[recipeId]['servings'] = newServings;
      });
    }
  }

  Future<void> _acceptRecipe() async {
    try {
      Recipe currentRecipe = _recipes[_currentRecipeIndex];
      await _updateRecipeInDatabase('recipeWeeklyMenu', currentRecipe, true);
      await _updateRecipeInDatabase('recipeHistory', currentRecipe, true);

      setState(() {
        _acceptedRecipes[_currentRecipeIndex] = true;
        _selectedCount++;
        _nextRecipe();
      });
    } catch (e) {
      _showErrorDialog("Error accepting recipe: $e");
    }
  }

  Future<void> _rejectRecipe() async {
    try {
      Recipe currentRecipe = _recipes[_currentRecipeIndex];
      await _updateRecipeInDatabase('recipeWeeklyMenu', currentRecipe, false);
      await _updateRecipeInDatabase('recipeHistory', currentRecipe, false);

      setState(() {
        _acceptedRecipes[_currentRecipeIndex] = false;
        _nextRecipe();
      });
    } catch (e) {
      _showErrorDialog("Error rejecting recipe: $e");
    }
  }

  void _nextRecipe() {
    int nextIndex = (_currentRecipeIndex + 1) % _recipes.length;
    while (_acceptedRecipes[nextIndex] &&
        _recipeWeeklyMenu.length < _recipes.length) {
      nextIndex = (nextIndex + 1) % _recipes.length;
    }
    _currentRecipeIndex = nextIndex;
    _checkAllRecipesAccepted();
  }

  void _checkAllRecipesAccepted() {
    if (_acceptedRecipes.every((isAccepted) => isAccepted)) {
      Navigator.pushReplacementNamed(context, '/no_recipe_selection_screen');
    }
  }

  Future<void> _onSaveRecipe() async {
    try {
      Recipe currentRecipe = _recipes[_currentRecipeIndex];
      bool newSavedState = !_savedRecipes[_currentRecipeIndex];
      await _updateRecipeInCollection(currentRecipe, saved: newSavedState);

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
      DatabaseReference weeklyMenuRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu');

      // Check if the recipe already exists in the weeklyMenu
      Query query = weeklyMenuRef.orderByChild('id').equalTo(recipe.id);
      DatabaseEvent event = await query.once();

      if (event.snapshot.value != null) {
        // Recipe exists, update it
        Map<dynamic, dynamic> recipeMap =
            event.snapshot.value as Map<dynamic, dynamic>;
        String key = recipeMap.keys.first;
        await weeklyMenuRef.child(key).update({
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
        await weeklyMenuRef.push().set(recipeData);
      }
    }
  }

  Future<void> _undoRecipe() async {
    if (_recipeWeeklyMenu.isNotEmpty) {
      try {
        String lastRecipeId = _recipeWeeklyMenu.keys.last;
        Recipe recipeToUndo =
            _recipes.firstWhere((recipe) => recipe.id == lastRecipeId);

        await _removeRecipeFromDatabase('recipeWeeklyMenu', recipeToUndo);
        await _removeRecipeFromDatabase('recipeHistory', recipeToUndo);

        setState(() {
          _currentRecipeIndex =
              _recipes.indexWhere((recipe) => recipe.id == lastRecipeId);
          if (_acceptedRecipes[_currentRecipeIndex]) {
            _selectedCount--;
          }
          _acceptedRecipes[_currentRecipeIndex] = false;
        });
      } catch (e) {
        _showErrorDialog("Error undoing action: $e");
      }
    }
  }

  Future<void> _removeRecipeFromDatabase(
      String databaseName, Recipe recipe) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child(databaseName);

      Map<String, dynamic> targetMap = databaseName == 'recipeWeeklyMenu'
          ? _recipeWeeklyMenu
          : _recipeHistory;

      if (targetMap.containsKey(recipe.id)) {
        await ref.child(targetMap[recipe.id]['key']).remove();
        targetMap.remove(recipe.id);

        // Update local state
        setState(() {
          if (databaseName == 'recipeWeeklyMenu') {
            _recipeWeeklyMenu = Map.from(targetMap);
          } else {
            _recipeHistory = Map.from(targetMap);
          }
        });
      }
    }
  }

  Future<void> _removeRecipeFromWeeklyMenu(Recipe recipe) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _recipeWeeklyMenuKeys.containsKey(recipe.id)) {
      DatabaseReference weeklyMenuRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu');

      await weeklyMenuRef.child(_recipeWeeklyMenuKeys[recipe.id]!).remove();
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

  Future<void> _addRecipeToWeeklyMenu(Recipe recipe,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference weeklyMenuRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu');

      Map<String, dynamic> recipeData = {
        'id': recipe.id,
        'name': recipe.name,
        'accepted': accepted,
        'timestamp': ServerValue.timestamp,
      };

      await weeklyMenuRef.push().set(recipeData);
    }
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
