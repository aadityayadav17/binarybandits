import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: ElevatedButton(
          onPressed: () {
            // Save profile logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6200EA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Save',
            style: GoogleFonts.robotoFlex(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
