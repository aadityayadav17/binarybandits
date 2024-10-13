import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SaveButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onPressed;

  const SaveButton({
    Key? key,
    required this.isSaved,
    required this.onPressed,
  }) : super(key: key);

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

    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSaved
              ? Colors.grey
              : const Color.fromRGBO(73, 160, 120, 1), // Color based on state
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                proportionalWidth(10)), // Proportional border radius
          ),
          fixedSize: Size(
            proportionalWidth(315), // Proportional button width
            proportionalHeight(48), // Proportional button height
          ),
        ),
        child: Text(
          isSaved ? 'Saved' : 'Save', // Text based on state
          style: GoogleFonts.robotoFlex(
            fontSize: proportionalFontSize(18), // Proportional font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
