import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/widgets/recipe_card_component.dart';
import 'package:binarybandits/screens/weekly_menu_screen/widgets/recipe_information_card.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';

class WeeklyMenuScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final int initialIndex;

  WeeklyMenuScreen({Key? key, required this.recipes, this.initialIndex = 0})
      : super(key: key);

  @override
  _WeeklyMenuScreenState createState() => _WeeklyMenuScreenState();
}

class _WeeklyMenuScreenState extends State<WeeklyMenuScreen> {
  late int _currentIndex;
  final ScrollController _scrollController = ScrollController();
  List<bool> _savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _savedRecipes = List.generate(widget.recipes.length, (_) => false);
  }

  void _nextRecipe() {
    if (_currentIndex < widget.recipes.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousRecipe() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _removeRecipe(int index) {
    setState(() {
      widget.recipes.removeAt(index);
      _savedRecipes.removeAt(index);
      if (_currentIndex >= widget.recipes.length) {
        _currentIndex = widget.recipes.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardTopPosition = screenHeight * 0.35;
    final cardHeight = screenHeight * 0.3;

    if (widget.recipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Menu'),
        ),
        body: Center(
          child: Text(
            'No more recipes',
            style: GoogleFonts.robotoFlex(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

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
      body: SizedBox(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My Menu",
                                style: GoogleFonts.robotoFlex(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 32,
                                    letterSpacing: 0,
                                    height: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${widget.recipes.length}',
                                style: GoogleFonts.robotoFlex(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                "Selected",
                                style: GoogleFonts.robotoFlex(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
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
                // Recipe Card
                Stack(
                  children: [
                    RecipeCardStack(
                      recipe: widget.recipes[_currentIndex],
                      isSaved: _savedRecipes[_currentIndex],
                      onSave: () {
                        setState(() {
                          _savedRecipes[_currentIndex] =
                              !_savedRecipes[_currentIndex];
                        });
                      },
                      onRemove: () => _removeRecipe(_currentIndex),
                      screenWidth: screenWidth - 30,
                      cardTopPosition: cardTopPosition,
                      cardHeight: cardHeight,
                      scrollController: _scrollController,
                    ),
                  ],
                ),
              ],
            ),
            RecipeInformationCard(
              key: ValueKey(widget.recipes[_currentIndex].id),
              recipe: widget.recipes[_currentIndex],
              topPosition: cardTopPosition + 50,
              cardHeight: cardHeight,
              scrollController: _scrollController,
              screenWidth: screenWidth,
            ),
            if (_currentIndex > 0)
              Positioned(
                left: -15,
                top: (screenHeight - 180) / 2,
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/screens/weekly_menu_screen/left.png',
                    width: 48,
                    height: 48,
                  ),
                  onPressed: _previousRecipe,
                ),
              ),
            if (_currentIndex < widget.recipes.length - 1)
              Positioned(
                right: -15,
                top: (screenHeight - 180) / 2,
                child: IconButton(
                  icon: Image.asset(
                    'assets/icons/screens/weekly_menu_screen/right.png',
                    width: 48,
                    height: 48,
                  ),
                  onPressed: _nextRecipe,
                ),
              ),
          ],
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeSelectionScreen(),
                ),
              );
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
      ),
    );
  }
}