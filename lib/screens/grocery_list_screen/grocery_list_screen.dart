import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';
import 'package:binarybandits/screens/recipe_selection_screen/recipe_selection_screen.dart';

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

class GroceryListScreen extends StatefulWidget {
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  bool cheapestOption = false;
  Map<int, bool> _selectedIngredients = {};

  @override
  void initState() {
    super.initState();
    // Initialize the selection map with false (unchecked) for each ingredient
    for (int i = 0; i < 10; i++) {
      _selectedIngredients[i] = false;
    }
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
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: proportionalWidth(context, 16),
              top: proportionalHeight(context, 10),
              bottom:
                  proportionalHeight(context, 0), // Reduced the bottom padding
            ),
            child: Text(
              "Grocery List",
              style: GoogleFonts.robotoFlex(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: proportionalFontSize(context, 32),
                height: 0.9,
              ),
            ),
          ),
// Cheapest Switch Row
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: proportionalWidth(context, 16)),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Right align the row contents
              children: [
                Text(
                  "Cheapest",
                  style: GoogleFonts.robotoFlex(
                    fontSize: proportionalFontSize(context, 12), // Smaller text
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: proportionalWidth(
                      context, 6), // Smaller space between text and switch
                ),
                Transform.scale(
                  scale: 0.7, // Further reduce the size of the switch
                  child: Switch(
                    value: cheapestOption,
                    onChanged: (value) {
                      setState(() {
                        cheapestOption = value;
                      });
                    },
                    activeColor: const Color.fromRGBO(
                        73, 160, 120, 1), // Set the active color
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              height: proportionalHeight(
                  context, 0)), // Add some spacing after the switch row
          // Store Filter Tabs Row
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: proportionalWidth(context, 16)),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align the tabs to the right
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .end, // Ensure tabs are right-aligned inside
                    children: [
                      _buildFilterTab("All", context),
                      _buildFilterTab("Coles", context),
                      _buildFilterTab("Woolworths", context),
                      _buildFilterTab("Aldi", context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: proportionalHeight(context, 16)),
          Expanded(
            child: _buildGroceryList(),
          ),
          Padding(
            padding: EdgeInsets.all(proportionalWidth(context, 16)),
            child: ElevatedButton(
              onPressed: () {
                // Add your action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                minimumSize:
                    Size(double.infinity, proportionalHeight(context, 50)),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(proportionalWidth(context, 10)),
                ),
              ),
              child: Text(
                'SAVE',
                style: GoogleFonts.robotoFlex(
                  color: Colors.white,
                  fontSize: proportionalFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Function for smaller filter tabs
  Widget _buildFilterTab(String label, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 2.0), // Smaller padding between tabs
      child: ElevatedButton(
        onPressed: () {
          // Action for filter
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          side: BorderSide(color: Colors.black.withOpacity(0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(
            horizontal: proportionalWidth(
                context, 8), // Adjust padding inside the button
            vertical: proportionalHeight(
                context, 4), // Reduce vertical height of the button
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.robotoFlex(
            fontSize: proportionalFontSize(
                context, 12), // Match text size to "Cheapest"
          ),
        ),
      ),
    );
  }

  Widget _buildGroceryList() {
    return ListView.builder(
      itemCount: 10, // Replace with your actual list count
      itemBuilder: (context, index) {
        bool isSelected = _selectedIngredients[index] ?? false;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 4.0), // Reduce vertical padding between items
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIngredients[index] = !isSelected;
                    });
                  },
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons
                            .radio_button_unchecked, // Checkmark or empty circle
                    color: isSelected
                        ? const Color.fromRGBO(
                            73, 160, 120, 1) // Active color for checkmark
                        : Colors.grey,
                    size: proportionalFontSize(context, 24),
                  ),
                ),
                title: Text(
                  'Ingredient name $index', // Replace with actual ingredient name
                  style: GoogleFonts.robotoFlex(
                    fontSize: proportionalFontSize(
                        context, 14), // Smaller font size for ingredients
                    color: isSelected
                        ? Colors.grey
                        : Colors.black, // Grey out text when checked
                    decoration: isSelected
                        ? TextDecoration.lineThrough
                        : null, // Strikethrough when checked
                  ),
                  maxLines:
                      null, // Allows text to wrap to a new line if necessary
                  overflow: TextOverflow
                      .visible, // Ensures text is visible when wrapped
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$XX',
                      style: TextStyle(
                          color: isSelected
                              ? Colors.grey
                              : Colors.black), // Price text color
                    ), // Placeholder for pricing
                    SizedBox(width: 10),
                    Text(
                      'None',
                      style: TextStyle(
                          color: isSelected
                              ? Colors.grey
                              : Colors.black), // Additional text color
                    ),
                    SizedBox(width: 10),
                    Text(
                      '\$XX',
                      style: TextStyle(
                          color: isSelected
                              ? Colors.grey
                              : Colors
                                  .black), // Another placeholder for pricing
                    ), // Another placeholder for pricing
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey.shade400, // Blunt line between items
              thickness: 1, // Thickness of the divider
              height: 1, // Reduce the gap around the divider
              indent: 16, // Padding on the left side of the divider
              endIndent: 16, // Padding on the right side of the divider
            ),
          ],
        );
      },
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeSelectionScreen(),
              ),
            );
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
            'assets/icons/bottom_navigation/discover-recipe-off.png',
            width: proportionalWidth(context, 22),
            height: proportionalHeight(context, 22),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/bottom_navigation/grocery-list-on.png',
            width: proportionalWidth(context, 26),
            height: proportionalHeight(context, 26),
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