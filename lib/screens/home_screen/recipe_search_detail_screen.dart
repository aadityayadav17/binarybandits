import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/models/recipe.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_collection_screen/widgets/recipe_card_component.dart';
import 'package:binarybandits/screens/recipe_selection_screen/widgets/recipe_information_card.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';

class RecipeSearchDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final ScrollController _scrollController = ScrollController();

  RecipeSearchDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Proportional sizing functions
    double proportionalFontSize(double size) => size * screenWidth / 375;
    double proportionalHeight(double size) => size * screenHeight / 812;
    double proportionalWidth(double size) => size * screenWidth / 375;

    final cardTopPosition = screenHeight * 0.35; // Top position for the card
    final cardHeight = screenHeight * 0.24; // Height for the card

    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        elevation: 0,
        toolbarHeight: proportionalHeight(60),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: proportionalWidth(8)),
          child: IconButton(
            icon: Image.asset(
              'assets/icons/screens/common/back-key.png',
              width: proportionalWidth(24),
              height: proportionalHeight(24),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight - proportionalHeight(60),
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: proportionalWidth(16),
                      top: proportionalHeight(10),
                      bottom: proportionalHeight(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recipe Search",
                              style: GoogleFonts.robotoFlex(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: proportionalFontSize(32),
                                  letterSpacing: 0,
                                  height: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RecipeCardStack(
                    recipe: recipe,
                    screenWidth: screenWidth,
                    cardTopPosition: cardTopPosition,
                    cardHeight: cardHeight,
                    scrollController: ScrollController(),
                  ),
                ],
              ),
              RecipeInformationCard(
                key: ValueKey(recipe.id),
                recipe: recipe,
                topPosition: cardTopPosition + proportionalHeight(30),
                cardHeight: cardHeight,
                scrollController: _scrollController,
                screenWidth: screenWidth,
              ),
              Positioned(
                top: cardTopPosition + proportionalHeight(260),
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Action for Add to My Menu button
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(proportionalWidth(10)),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: proportionalWidth(120),
                          vertical: proportionalHeight(12),
                        ),
                      ),
                      child: Text(
                        'Add to My Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: proportionalFontSize(16),
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
              width: proportionalWidth(24),
              height: proportionalHeight(24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/discover-recipe-off.png',
              width: proportionalWidth(22),
              height: proportionalHeight(22),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/grocery-list-off.png',
              width: proportionalWidth(24),
              height: proportionalHeight(24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/weekly-menu-off.png',
              width: proportionalWidth(24),
              height: proportionalHeight(24),
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
