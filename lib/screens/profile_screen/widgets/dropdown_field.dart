/// A custom dropdown field widget that allows users to select an option from a list of items.
///
/// The `DropdownField` widget is a stateful widget that displays a dropdown menu with a label.
/// It supports proportional sizing based on the screen dimensions and uses custom fonts and styles.
///
/// The widget takes the following parameters:
///
/// - `labelText`: A [String] that represents the label text displayed above the dropdown.
/// - `currentValue`: A nullable [String] that represents the currently selected value in the dropdown.
/// - `items`: A [List<String>] that contains the items to be displayed in the dropdown menu.
/// - `onChanged`: A [ValueChanged<String?>] callback that is called when the selected value changes.
///
/// The widget uses the `DropdownButton2` package for the dropdown functionality and the `google_fonts`
/// package for custom fonts. It also includes custom styling for the dropdown menu, items, and icons.
library dropdown_field;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class DropdownField extends StatefulWidget {
  final String labelText;
  final String? currentValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  // Add controller to constructor
  const DropdownField({
    super.key,
    required this.labelText,
    required this.currentValue,
    required this.items,
    required this.onChanged,
  });

  @override
  DropdownFieldState createState() => DropdownFieldState();
}

class DropdownFieldState extends State<DropdownField> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Define proportional sizes based on screen dimensions
    double proportionalFontSize(double size) =>
        size * screenWidth / 375; // Assuming base screen width is 375
    double proportionalHeight(double size) =>
        size * screenHeight / 812; // Assuming base screen height is 812
    double proportionalWidth(double size) => size * screenWidth / 375;

    return Container(
      width: proportionalWidth(300), // Proportional width for the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
            proportionalWidth(10)), // Proportional border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: proportionalWidth(1),
            blurRadius: proportionalWidth(5),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: proportionalWidth(16),
        vertical: proportionalHeight(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: GoogleFonts.roboto(
              fontSize: proportionalFontSize(14),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Select Option',
                style: GoogleFonts.roboto(
                  fontSize: proportionalFontSize(16),
                  color: Colors.black,
                ),
              ),
              value: widget.currentValue,
              onChanged: widget.onChanged,
              onMenuStateChange: (isOpen) {
                setState(() {
                  _isDropdownOpen = isOpen;
                });
              },
              items: widget.items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.roboto(
                      fontSize: proportionalFontSize(16),
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return widget.items.map((String item) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      style: GoogleFonts.roboto(
                        fontSize: proportionalFontSize(16),
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList();
              },
              iconStyleData: IconStyleData(
                icon: Image.asset(
                  _isDropdownOpen
                      ? 'assets/icons/screens/profile_screen/dropdown-off-display.png'
                      : 'assets/icons/screens/profile_screen/dropdown-on-display.png',
                  width: proportionalWidth(24),
                  height: proportionalHeight(24),
                ),
                iconSize: proportionalWidth(24),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: proportionalHeight(200),
                width: proportionalWidth(268),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(proportionalWidth(10)),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: Radius.circular(proportionalWidth(40)),
                  thickness: WidgetStateProperty.all(proportionalWidth(6)),
                  thumbVisibility: WidgetStateProperty.all(true),
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                height: proportionalHeight(40),
                padding: EdgeInsets.symmetric(
                  horizontal: proportionalWidth(8),
                ),
                selectedMenuItemBuilder: (context, child) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
