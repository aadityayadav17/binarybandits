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
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSaved ? Colors.grey : Colors.green, // Color based on state
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          fixedSize: Size(315, 48), // Fixed size for the button
        ),
        child: Text(
          isSaved ? 'Saved' : 'Save', // Text based on state
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
