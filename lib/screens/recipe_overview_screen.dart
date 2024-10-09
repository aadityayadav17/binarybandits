import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen.dart';

class RecipeOverviewScreen extends StatefulWidget {
  const RecipeOverviewScreen({Key? key}) : super(key: key);

  @override
  _RecipeOverviewScreenState createState() => _RecipeOverviewScreenState();
}

class _RecipeOverviewScreenState extends State<RecipeOverviewScreen> {
  List<Recipe> _recipes = [];
  List<int> _servings = []; // Change from int to List<int>
  int _currentRecipeIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _recipes = jsonData.map((data) => Recipe.fromJson(data)).toList();
      _servings = List<int>.filled(_recipes.length,
          1); // Initialize servings list with 1 for each recipe
      _pageController = PageController(
        initialPage: _currentRecipeIndex,
        viewportFraction: 0.8,
      );
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _applyAllServings() {
    int currentServing = _servings[_currentRecipeIndex];
    setState(() {
      _servings = List<int>.filled(_recipes.length, currentServing);
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _recipes.isEmpty || _pageController == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You successfully added ${_recipes.length} recipes to the My Menu!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
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
                                  height: 300,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: child,
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.asset(
                                          recipe.image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 260,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: Text(
                                                recipe.name,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 16,
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
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: Image.asset(
                                      'assets/icons/screens/recipe_overview_screen/cross.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (index == _recipes.length - 1 &&
                                            _recipes.length > 1) {
                                          _currentRecipeIndex--;
                                        } else if (_recipes.length > 1) {
                                          _currentRecipeIndex++;
                                        }
                                        _recipes.removeAt(index);
                                        _servings.removeAt(index);
                                        if (_recipes.isNotEmpty) {
                                          _pageController
                                              ?.jumpToPage(_currentRecipeIndex);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _currentRecipeIndex.toDouble(),
                      min: 0,
                      max: (_recipes.length - 1).toDouble(),
                      divisions: _recipes.length - 1,
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
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'How many servings for this recipe?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
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
                          minWidth: 150,
                          maxWidth: 180,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                'assets/icons/screens/recipe_overview_screen/minus.png',
                                width: 12,
                                height: 12,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_servings[_currentRecipeIndex] > 1) {
                                    _servings[_currentRecipeIndex]--;
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${_servings[_currentRecipeIndex]}',
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: Image.asset(
                                'assets/icons/screens/recipe_overview_screen/add.png',
                                width: 12,
                                height: 12,
                              ),
                              onPressed: () {
                                setState(() {
                                  _servings[_currentRecipeIndex]++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Apply All',
                              style: TextStyle(
                                  color: const Color.fromRGBO(73, 160, 120, 1)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle Next
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(73, 160, 120, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(color: Colors.white),
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
}
