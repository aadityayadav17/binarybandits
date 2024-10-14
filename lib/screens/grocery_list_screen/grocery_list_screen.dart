import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binarybandits/screens/home_screen/home_screen.dart';
import 'package:binarybandits/screens/weekly_menu_screen/weekly_menu_screen.dart';

class GroceryListScreen extends StatefulWidget {
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  bool cheapestOption = false;

  @override
  Widget build(BuildContext context) {
    double proportionalFontSize(double size) =>
        size * MediaQuery.of(context).size.width / 375;
    double proportionalHeight(double size) =>
        size * MediaQuery.of(context).size.height / 812;
    double proportionalWidth(double size) =>
        size * MediaQuery.of(context).size.width / 375;

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
              left: proportionalWidth(16),
              top: proportionalHeight(10),
              bottom: proportionalHeight(16),
            ),
            child: Text(
              "Grocery List",
              style: GoogleFonts.robotoFlex(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: proportionalFontSize(32),
                height: 0.9,
              ),
            ),
          ),
          // Cheapest Switch Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: proportionalWidth(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cheapest",
                  style: GoogleFonts.robotoFlex(
                    fontSize: proportionalFontSize(16),
                    color: Colors.black,
                  ),
                ),
                Switch(
                  value: cheapestOption,
                  onChanged: (value) {
                    setState(() {
                      cheapestOption = value;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: proportionalHeight(10)),
          // Store Filter Tabs Row
          Padding(
            padding: EdgeInsets.only(left: proportionalWidth(16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterTab("All"),
                  _buildFilterTab("Coles"),
                  _buildFilterTab("Woolworths"),
                  _buildFilterTab("Aldi"),
                ],
              ),
            ),
          ),
          SizedBox(height: proportionalHeight(16)),
          Expanded(
            child: _buildGroceryList(),
          ),
          Padding(
            padding: EdgeInsets.all(proportionalWidth(16)),
            child: ElevatedButton(
              onPressed: () {
                // Add your action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(73, 160, 120, 1),
                minimumSize: Size(double.infinity, proportionalHeight(50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(proportionalWidth(10)),
                ),
              ),
              child: Text(
                'SAVE',
                style: GoogleFonts.robotoFlex(
                  color: Colors.white,
                  fontSize: proportionalFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterTab(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        onPressed: () {
          // Action for filter
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Corrected from 'primary'
          foregroundColor: Colors.black, // Corrected from 'onPrimary'
          elevation: 0,
          side: BorderSide(color: Colors.black.withOpacity(0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildGroceryList() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.check_circle, color: Colors.white),
            ),
            title: Text('Ingredient name'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$XX'),
                SizedBox(width: 10),
                Text('None'),
                SizedBox(width: 10),
                Text('\$XX'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      currentIndex: 2,
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
            // Add action for second tab
            break;
          case 2:
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
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: '',
        ),
      ],
    );
  }
}
