import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen.dart';

class IngredientListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromRGBO(245, 245, 245, 1), // Updated background color
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(
            245, 245, 245, 1), // AppBar background color matching the screen
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
      body: Column(
        children: [
          // Left-align the "Ingredient List" text
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10.0),
            child: Align(
              alignment:
                  Alignment.centerLeft, // Ensure the text is left-aligned
              child: Text(
                "Ingredient List",
                style: GoogleFonts.robotoFlex(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  letterSpacing: 0,
                  height: 0.9,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Recipe Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRecipeTab('All', true),
                  _buildRecipeTab('Recipe 1', false),
                  _buildRecipeTab('Recipe 2', false),
                  _buildRecipeTab('Recipe 3', false),
                ],
              ),
            ),
          ),
          // Add all button and item count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Add all ingredients to grocery list logic
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add all', style: GoogleFonts.robotoFlex()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                  ),
                ),
                Text(
                  '10 Items',
                  style: GoogleFonts.robotoFlex(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Ingredients List
          Expanded(
            child: ListView.builder(
              itemCount: 10, // dynamic based on your ingredient list
              itemBuilder: (context, index) {
                return _buildIngredientCard();
              },
            ),
          ),
          // Add to Grocery List button
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Add selected ingredients to grocery list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Add to Grocery List',
                style: GoogleFonts.robotoFlex(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(245, 245, 245,
            1), // Updated background color for the bottom navigation bar
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

  Widget _buildRecipeTab(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Change selected tab logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green[400] : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: StadiumBorder(),
        ),
        child: Text(
          title,
          style: GoogleFonts.robotoFlex(),
        ),
      ),
    );
  }

  Widget _buildIngredientCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.green),
            onPressed: () {
              // Add single ingredient to grocery list logic
            },
          ),
          title: Text(
            'Ingredient name',
            style: GoogleFonts.robotoFlex(),
          ),
          trailing: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(''),
          ),
        ),
      ),
    );
  }
}
