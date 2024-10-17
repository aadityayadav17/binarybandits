import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/ingredient_list_screen/ingredient_list_screen.dart';
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

class RecipeOverviewScreen extends StatefulWidget {
  const RecipeOverviewScreen({Key? key}) : super(key: key);

  @override
  _RecipeOverviewScreenState createState() => _RecipeOverviewScreenState();
}

class _RecipeOverviewScreenState extends State<RecipeOverviewScreen> {
  List<Recipe> _recipes = [];
  Map<String, int> _servings = {}; // Map for servings
  int _currentRecipeIndex = 0;
  PageController? _pageController;
  Map<String, dynamic> _recipeWeeklyMenu = {};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not authenticated');
      return;
    }

    final userId = user.uid;
    final databaseRef =
        FirebaseDatabase.instance.ref("users/$userId/recipeWeeklyMenu");
    final snapshot = await databaseRef.get();

    if (snapshot.exists) {
      final weeklyMenuData = snapshot.value as Map<dynamic, dynamic>;
      _recipeWeeklyMenu.clear();
      _servings.clear();

      final acceptedRecipes = weeklyMenuData.entries
          .where((entry) => entry.value['accepted'] == true)
          .map((entry) => {
                'id': entry.value['id'],
                'key': entry.key,
                'servings': entry.value['servings'] ?? 1,
              })
          .toList();

      final jsonString = await rootBundle
          .loadString('assets/recipes/D3801 Recipes - Recipes.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      final matchedRecipes = jsonData.where((recipeData) {
        return acceptedRecipes.any((acceptedRecipe) =>
            acceptedRecipe['id'] == recipeData['recipe_id']);
      }).toList();

      setState(() {
        _recipes = matchedRecipes.map((data) => Recipe.fromJson(data)).toList();
        _pageController = PageController(
            initialPage: _currentRecipeIndex, viewportFraction: 0.8);

        // Populate _recipeWeeklyMenu and _servings
        for (var recipe in acceptedRecipes) {
          _recipeWeeklyMenu[recipe['id']] = recipe['key'];
          _servings[recipe['id']] = recipe['servings'];
        }
      });
    } else {
      print('No meal plan data available.');
    }
  }

  Future<void> _updateServingsInDatabase(String recipeId, int servings) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _recipeWeeklyMenu.containsKey(recipeId)) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu')
          .child(_recipeWeeklyMenu[recipeId]);

      await ref.update({
        'servings': servings,
        'timestamp': ServerValue.timestamp,
      });
    }
  }

  void _adjustServings(String recipeId, bool increase) {
    setState(() {
      if (increase) {
        _servings[recipeId] = (_servings[recipeId] ?? 1) + 1;
      } else if ((_servings[recipeId] ?? 1) > 1) {
        _servings[recipeId] = (_servings[recipeId] ?? 1) - 1;
      }
    });
    _updateServingsInDatabase(recipeId, _servings[recipeId] ?? 1);
  }

  Future<void> _updateRecipeInWeeklyMenu(String recipeId,
      {required bool accepted}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _recipeWeeklyMenu.containsKey(recipeId)) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('recipeWeeklyMenu')
          .child(_recipeWeeklyMenu[recipeId]);

      await ref.update({
        'accepted': accepted,
        'timestamp': ServerValue.timestamp,
      });
    }
  }

  Future<void> _removeRecipe(int index) async {
    Recipe recipeToRemove = _recipes[index];
    try {
      await _updateRecipeInWeeklyMenu(recipeToRemove.id, accepted: false);

      setState(() {
        _recipes.removeAt(index);
        _servings.remove(recipeToRemove.id);
        _recipeWeeklyMenu.remove(recipeToRemove.id);

        if (_recipes.isEmpty) {
          _currentRecipeIndex = 0;
        } else if (index <= _currentRecipeIndex) {
          _currentRecipeIndex =
              (_currentRecipeIndex - 1).clamp(0, _recipes.length - 1);
        }

        if (_recipes.isNotEmpty) {
          _pageController?.jumpToPage(_currentRecipeIndex);
        }
      });
    } catch (e) {
      print('Error removing recipe: $e');
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _applyAllServings() {
    final currentServings = _servings[_recipes[_currentRecipeIndex].id] ?? 1;
    setState(() {
      for (var recipe in _recipes) {
        _servings[recipe.id] = currentServings;
        _updateServingsInDatabase(recipe.id, currentServings);
      }
    });
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _recipes.isEmpty || _pageController == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(proportionalWidth(context, 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You successfully added ${_recipes.length} recipes to the My Meal Plan!',
                      style: TextStyle(
                        fontSize: proportionalFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: proportionalHeight(context, 16)),
                    SizedBox(
                      height: proportionalHeight(context, 300),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentRecipeIndex = index;
                          });
                        },
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return AnimatedBuilder(
                            animation: _pageController!,
                            builder: (context, child) {
                              return Center(
                                child: SizedBox(
                                  height: proportionalHeight(context, 300),
                                  width: proportionalWidth(context, 300),
                                  child: child,
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        proportionalWidth(context, 15)),
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            proportionalWidth(context, 15)),
                                        child: Image.asset(
                                          recipe.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height:
                                              proportionalHeight(context, 260),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(
                                                  proportionalWidth(
                                                      context, 15)),
                                              bottomRight: Radius.circular(
                                                  proportionalWidth(
                                                      context, 15)),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: proportionalWidth(
                                                    context, 4),
                                              ),
                                              child: Text(
                                                recipe.name,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize:
                                                      proportionalFontSize(
                                                          context, 16),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: proportionalHeight(context, 10),
                                  right: proportionalWidth(context, 10),
                                  child: IconButton(
                                    icon: Image.asset(
                                      'assets/icons/screens/recipe_overview_screen/cross.png',
                                      width: proportionalWidth(context, 16),
                                      height: proportionalHeight(context, 16),
                                    ),
                                    onPressed: () => _removeRecipe(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: proportionalHeight(context, 0)),
                    Slider(
                      value: _currentRecipeIndex.toDouble(),
                      min: 0,
                      max: (_recipes.length - 1).toDouble(),
                      divisions: _recipes.length > 1
                          ? _recipes.length - 1
                          : null, // Fix here
                      label:
                          'Recipe ${_currentRecipeIndex + 1} of ${_recipes.length}',
                      activeColor: const Color.fromRGBO(73, 160, 120, 1),
                      inactiveColor: Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          _currentRecipeIndex = value.toInt();
                        });
                        _pageController?.jumpToPage(_currentRecipeIndex);
                      },
                    ),
                    SizedBox(height: proportionalHeight(context, 0)),
                    Center(
                      child: Text(
                        'How many servings for this recipe?',
                        style: TextStyle(
                          fontSize: proportionalFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: proportionalHeight(context, 16)),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              proportionalWidth(context, 24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(
                          minWidth: proportionalWidth(context, 150),
                          maxWidth: proportionalWidth(context, 180),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: proportionalWidth(context, 16)),
                              child: IconButton(
                                icon: Image.asset(
                                  (_servings[_recipes[_currentRecipeIndex]
                                                  .id] ??
                                              1) >
                                          1
                                      ? 'assets/icons/screens/recipe_overview_screen/minus-enabled.png'
                                      : 'assets/icons/screens/recipe_overview_screen/minus-disabled.png',
                                  width: proportionalWidth(context, 12),
                                  height: proportionalHeight(context, 12),
                                ),
                                onPressed: (_servings[
                                                _recipes[_currentRecipeIndex]
                                                    .id] ??
                                            1) >
                                        1
                                    ? () => _adjustServings(
                                        _recipes[_currentRecipeIndex].id, false)
                                    : null,
                              ),
                            ),
                            Text(
                              '${_servings[_recipes[_currentRecipeIndex].id] ?? 1}',
                              style: TextStyle(
                                  fontSize: proportionalFontSize(context, 24)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: proportionalWidth(context, 16)),
                              child: IconButton(
                                icon: Image.asset(
                                  'assets/icons/screens/recipe_overview_screen/add.png',
                                  width: proportionalWidth(context, 12),
                                  height: proportionalHeight(context, 12),
                                ),
                                onPressed: () => _adjustServings(
                                    _recipes[_currentRecipeIndex].id, true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: proportionalHeight(context, 16)),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _applyAllServings();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color.fromRGBO(73, 160, 120, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    proportionalWidth(context, 8)),
                              ),
                            ),
                            child: Text(
                              'Apply All',
                              style: TextStyle(
                                color: const Color.fromRGBO(73, 160, 120, 1),
                                fontSize: proportionalFontSize(context, 16),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: proportionalWidth(context, 16)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => IngredientListPage(),
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(73, 160, 120, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    proportionalWidth(context, 8)),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: proportionalFontSize(context, 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}
