import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';
import 'package:binarybandits/screens/grocery_list_screen/grocery_list_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';

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

// Helper to open URLs
void _launchURL(String url) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

class ReferencesPage extends StatelessWidget {
  const ReferencesPage({Key? key}) : super(key: key);

  Widget _buildImageWithText(
      BuildContext context, String imagePath, String description, String url) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: proportionalHeight(context, 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imagePath,
              width: proportionalWidth(context, 60),
              height: proportionalHeight(context, 60),
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: proportionalWidth(context, 16)),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchURL(url),
              child: Text(
                description,
                style: GoogleFonts.robotoFlex(
                  fontSize: proportionalFontSize(context, 14),
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: proportionalWidth(context, 16),
        ),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: proportionalHeight(context, 10),
                bottom: proportionalHeight(context, 16),
              ),
              child: Text(
                "References",
                style: GoogleFonts.robotoFlex(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: proportionalFontSize(context, 32),
                  height: 0.9,
                ),
              ),
            ),
            _buildImageWithText(
                context,
                'assets/images/home_screen/discover-recipe.png',
                "Designed by Freepik",
                "https://www.freepik.com/free-photo/top-view-pasta-waffles-with-copy-space_7087845.htm#fromView=search&page=1&position=27&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895"),
            _buildImageWithText(
                context,
                'assets/images/home_screen/grocery-list.png',
                "Designed by Freepik",
                "https://www.freepik.com/free-photo/lime-near-roasted-meat-salad_1488613.htm#fromView=search&page=1&position=28&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895"),
            _buildImageWithText(
                context,
                'assets/images/home_screen/recipe-collection.png',
                "Designed by Freepik",
                "https://www.freepik.com/free-photo/buddha-bowl-dish-with-chicken-fillet-rice-red-cabbage-carrot-fresh-lettuce-salad-sesame_7537371.htm#fromView=search&page=4&position=44&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895"),
            _buildImageWithText(
                context,
                'assets/images/home_screen/recipe-history.png',
                "Designed by Freepik",
                "https://www.freepik.com/free-photo/copy-space-bowl-with-salad_7763035.htm#fromView=search&page=2&position=5&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895"),
            _buildImageWithText(
                context,
                'assets/images/home_screen/weekly-menu.png',
                "Designed by Freepik",
                "https://www.freepik.com/free-photo/flat-lay-batch-cooking-assortment-with-copy-space_11273706.htm#fromView=search&page=3&position=28&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895"),
            SizedBox(height: proportionalHeight(context, 16)),
            Text(
              "Icons used in the Application -\nUicons by Flaticon [https://www.flaticon.com/uicons]\n",
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
            SizedBox(height: proportionalHeight(context, 16)),
            Text(
              "Recipes generated using -\nThis recipes were created with the assistance of GPT4o\n",
            ),
            SizedBox(height: proportionalHeight(context, 16)),
            Text(
              "Recipe Images generated using -\nThis image was created with the assistance of DALL·E 3\n",
            ),
            SizedBox(height: proportionalHeight(context, 16)),
            Text(
              "Products from Aldi for Grocery List fetched from -\nhttps://github.com/donde-esta-la-biblioteca/Woolworths-Coles-IGA/blob/main/1.%20Cleaned%20Data/Aldi.csv\n",
            ),
            Text(
              "Products from Coles for Grocery List fetched from -\nhttps://raw.githubusercontent.com/donde-esta-la-biblioteca/Woolworths-Coles-IGA/refs/heads/main/1.%20Cleaned%20Data/Coles.csv\n",
            ),
            Text(
              "Products from Woolworths for Grocery List fetched from -\nhttps://github.com/donde-esta-la-biblioteca/Woolworths-Coles-IGA/blob/main/1.%20Cleaned%20Data/Woolworths.csv\n",
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Assuming this is the second tab
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
              'assets/icons/bottom_navigation/home-off.png',
              width: proportionalWidth(context, 24),
              height: proportionalHeight(context, 24),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/bottom_navigation/discover-recipe-off.png',
              width: proportionalWidth(context, 22),
              height: proportionalHeight(context, 22),
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
