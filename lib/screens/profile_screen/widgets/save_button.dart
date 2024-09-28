import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Save profile logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // Changed to green
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Changed to 10
          ),
          padding: const EdgeInsets.symmetric(horizontal: 135, vertical: 12),
        ),
        child: Text(
          'Save', // Changed from 'Save' to 'Done'
          style: GoogleFonts.robotoFlex(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
