import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen.dart';
import 'package:binarybandits/screens/recipe_overview_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_card_components.dart';

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
  int _selectedCount = 0;
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
    final jsonString = await rootBundle
        .loadString('assets/recipes/D3801 Recipes - Recipes.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _recipes = jsonData.map((data) => Recipe.fromJson(data)).toList();
      _savedRecipes = List.generate(_recipes.length, (_) => false);
      _acceptedRecipes = List.generate(_recipes.length, (_) => false);
    });
  }

  void _nextRecipe({bool accepted = false}) {
    setState(() {
      _acceptedRecipes[_currentRecipeIndex] = accepted;
      _recipeHistory.add(_currentRecipeIndex);
      _currentRecipeIndex = (_currentRecipeIndex + 1) % _recipes.length;
      _scrollController.jumpTo(0);
    });
  }

  void _undoRecipe() {
    if (_recipeHistory.isNotEmpty) {
      setState(() {
        int previousIndex = _recipeHistory.removeLast();
        if (_acceptedRecipes[previousIndex]) {
          _selectedCount--;
          _acceptedRecipes[previousIndex] = false;
        }
        _currentRecipeIndex = previousIndex;
        _scrollController.jumpTo(0);
      });
    }
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _isDragging = true;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final dragDistance = details.localPosition.dx - _dragStartX;
    final screenWidth = MediaQuery.of(context).size.width;
    final swipePercentage = dragDistance / screenWidth;

    setState(() {
      _swipeAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(swipePercentage, 0),
      ).animate(_swipeController);
    });

    _swipeController.value = swipePercentage.abs();
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    if (_swipeController.value > 0.2) {
      if (_swipeAnimation.value.dx > 0) {
        _acceptRecipe();
      } else {
        _rejectRecipe();
      }
    } else {
      _resetSwipe();
    }
  }

  void _acceptRecipe() {
    _swipeController.forward().then((_) {
      setState(() {
        _selectedCount++;
        _nextRecipe(accepted: true);
        _resetSwipe();
      });
    });
  }

  void _rejectRecipe() {
    _swipeController.forward().then((_) {
      setState(() {
        _nextRecipe(accepted: false);
        _resetSwipe();
      });
    });
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
    final cardTopPosition = screenHeight * 0.35;
    final cardHeight = screenHeight * 0.24;

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
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
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight - 60,
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Discover\nRecipe",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 32,
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
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Text(
                                    "Selected",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
                      cardTopPosition: cardTopPosition,
                      cardHeight: cardHeight,
                      scrollController: _scrollController,
                    ),
                  ],
                ),
                Positioned(
                  top: cardTopPosition + 260,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                        'assets/icons/screens/recipe_selection_screen/recipe-rejected.png',
                        _rejectRecipe,
                      ),
                      const SizedBox(width: 16),
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 12),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        'assets/icons/screens/recipe_selection_screen/recipe-reject-accept-rectangle.png',
                        'assets/icons/screens/recipe_selection_screen/recipe-accepted.png',
                        _acceptRecipe,
                      ),
                    ],
                  ),
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
      ),
    );
  }

  Widget _buildActionButton(
      String backgroundPath, String iconPath, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
      ),
      child: Stack(
        children: [
          Image.asset(backgroundPath, width: 62, height: 62),
          Positioned(
            top: 18,
            left: 18,
            child: Image.asset(iconPath, width: 20, height: 20),
          ),
        ],
      ),
    );
  }
}
