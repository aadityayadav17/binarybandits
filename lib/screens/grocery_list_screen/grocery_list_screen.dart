import 'package:flutter/material.dart';
import 'dart:ui';
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
  String selectedTab = "All"; // Default selected tab is "All"
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

  // Prices are now stored as Strings, not doubles
  List<Map<String, String>> ingredientPrices = [
    {"Coles": "10.00", "Woolworths": "12.49", "Aldi": "8.99"},
    {"Coles": "15.50", "Woolworths": "16.00", "Aldi": "14.75"},
    {"Coles": "200.99", "Woolworths": "220.00", "Aldi": "180.45"},
    // Add more items with prices for each store...
  ];

// Since the prices are stored as Strings, just return the string values as they are
  String formatPrice(String? price) {
    if (price == null || price.isEmpty) return "None";
    return "\$$price"; // Add the dollar sign before the price
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
                    onChanged: selectedTab == "All"
                        ? (value) {
                            setState(() {
                              cheapestOption = value;
                            });
                          }
                        : null, // Disable for individual tabs
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
          buildInfoBox(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Function for smaller filter tabs
  Widget _buildFilterTab(String label, BuildContext context) {
    bool isSelected =
        selectedTab == label; // Check if this tab is the selected one

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 2.0), // Smaller padding between tabs
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTab = label; // Update selected tab when this tab is clicked
            if (selectedTab != "All") {
              cheapestOption =
                  false; // Ensure the cheapest option is turned off when a specific store is selected
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromRGBO(
                  73, 160, 120, 1) // Active tab background color
              : Colors.white, // Inactive tab background color
          foregroundColor: isSelected
              ? Colors.white // Active tab text color
              : Colors.black, // Inactive tab text color
          elevation: 0,
          side: BorderSide(
            color: isSelected
                ? Colors.transparent // No border for the active tab
                : Colors.black.withOpacity(0.2), // Border for inactive tabs
          ),
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
    // Define unique product names for each tab
    List<String> colesProductNames = [
      "Coles Product 1", "Coles Product 2", "Coles Product 3", "Coles Product 4"
      // Add more unique names for Coles
    ];

    List<String> woolworthsProductNames = [
      "Woolworths Product 1", "Woolworths Product 2", "Woolworths Product 3",
      "Woolworths Product 4"
      // Add more unique names for Woolworths
    ];

    List<String> aldiProductNames = [
      "Aldi Product 1", "Aldi Product 2", "Aldi Product 3", "Aldi Product 4"
      // Add more unique names for Aldi
    ];

    return ListView.builder(
      itemCount: ingredientPrices.length, // Replace with your actual list count
      itemBuilder: (context, index) {
        bool isSelected = _selectedIngredients[index] ?? false;

        // Determine the product name based on the selected tab
        String itemLabel =
            'Unknown'; // Default value to ensure it's always initialized
        if (selectedTab == "All") {
          itemLabel =
              'Ingredient name $index'; // Use Ingredient name for "All" tab
        } else if (selectedTab == "Coles") {
          itemLabel = colesProductNames[index]; // Use Coles product names
        } else if (selectedTab == "Woolworths") {
          itemLabel =
              woolworthsProductNames[index]; // Use Woolworths product names
        } else if (selectedTab == "Aldi") {
          itemLabel = aldiProductNames[index]; // Use Aldi product names
        }

        // Check if "All" tab is selected, display prices for all stores in aligned columns
        if (selectedTab == "All") {
          double? colesPrice =
              double.tryParse(ingredientPrices[index]["Coles"] ?? '0');
          double? woolworthsPrice =
              double.tryParse(ingredientPrices[index]["Woolworths"] ?? '0');
          double? aldiPrice =
              double.tryParse(ingredientPrices[index]["Aldi"] ?? '0');

          // Find the lowest price
          double? lowestPrice = [colesPrice, woolworthsPrice, aldiPrice]
              .where((price) => price != null && price > 0)
              .reduce((a, b) => a! < b! ? a : b);

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
                    '$itemLabel', // Dynamically display the label based on the selected tab
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
                      // Coles price, aligned to a fixed width
                      SizedBox(
                        width: proportionalWidth(
                            context, 50), // Fixed width for Coles price
                        child: Text(
                          formatPrice(ingredientPrices[index]["Coles"]),
                          style: TextStyle(
                            color: cheapestOption && lowestPrice == colesPrice
                                ? Colors.black
                                : Colors
                                    .grey, // Highlight the cheapest price in black
                          ),
                          textAlign: TextAlign
                              .end, // Align to the right for consistency
                        ),
                      ),
                      SizedBox(width: 10), // Space between columns
                      // Woolworths price, aligned to a fixed width
                      SizedBox(
                        width: proportionalWidth(
                            context, 50), // Fixed width for Woolworths price
                        child: Text(
                          formatPrice(ingredientPrices[index]["Woolworths"]),
                          style: TextStyle(
                            color: cheapestOption &&
                                    lowestPrice == woolworthsPrice
                                ? Colors.black
                                : Colors
                                    .grey, // Highlight the cheapest price in black
                          ),
                          textAlign: TextAlign
                              .end, // Align to the right for consistency
                        ),
                      ),
                      SizedBox(width: 10), // Space between columns
                      // Aldi price, aligned to a fixed width
                      SizedBox(
                        width: proportionalWidth(
                            context, 50), // Fixed width for Aldi price
                        child: Text(
                          formatPrice(ingredientPrices[index]["Aldi"]),
                          style: TextStyle(
                            color: cheapestOption && lowestPrice == aldiPrice
                                ? Colors.black
                                : Colors
                                    .grey, // Highlight the cheapest price in black
                          ),
                          textAlign: TextAlign
                              .end, // Align to the right for consistency
                        ),
                      ),
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
        } else {
          // For individual store tabs (Coles, Woolworths, Aldi), display only one price
          String displayedPrice =
              formatPrice(ingredientPrices[index][selectedTab]);

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
                    '$itemLabel', // Display distinct Product name for individual tabs
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
                  trailing: Text(
                    displayedPrice, // Display the price for the selected store
                    style: const TextStyle(
                        color: Colors.grey), // Price is always grey
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
        }
      },
    );
  }

  // Method for the rounded rectangle information box
  Widget buildInfoBox(BuildContext context) {
    int totalItems =
        ingredientPrices.length; // Get the total number of items dynamically

    return Container(
      margin:
          EdgeInsets.only(bottom: 0), // Align with the bottom navigation bar
      child: ClipRRect(
        // Clip the blur effect to the rounded corners
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(proportionalWidth(context, 10)),
          topRight: Radius.circular(proportionalWidth(context, 10)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Apply blur
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: proportionalHeight(context, 16),
              horizontal: proportionalWidth(context, 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white, // Semi-transparent for frosted effect
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(proportionalWidth(context, 24)),
                topRight: Radius.circular(proportionalWidth(context, 24)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3), // Subtle shadow
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Offset for the shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total $totalItems items', // Display the total number of items
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$XXXXX', // Placeholder for total cost
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: proportionalHeight(context, 8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your budget', // Budget label
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$XXXXX', // Placeholder for budget
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: proportionalHeight(context, 8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SAVE', // Action label
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$XXXXX', // Placeholder for amount to be saved
                      style: GoogleFonts.robotoFlex(
                        fontSize: proportionalFontSize(context, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
