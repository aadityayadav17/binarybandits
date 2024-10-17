import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller; // Controller to manage phone input
  final Function(String) onChanged;

  const PhoneNumberField({
    Key? key,
    required this.labelText,
    required this.controller, // Pass the controller as a required parameter
    required this.onChanged,
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
            labelText,
            style: GoogleFonts.roboto(
              fontSize: proportionalFontSize(14),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797),
            ),
          ),
          SizedBox(height: proportionalHeight(8)),
          Row(
            children: [
              CountryCodePicker(
                onChanged: (countryCode) {
                  // Optional: Handle country code changes
                },
                initialSelection: 'AU',
                favorite: const ['+61', 'AU'],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
                textStyle: GoogleFonts.roboto(
                  fontSize: proportionalFontSize(16),
                  color: const Color(0xFF979797), // Set the color to 0xFF979797
                ),
                padding: EdgeInsets.zero,
              ),
              SizedBox(width: proportionalWidth(12)),
              Expanded(
                child: TextField(
                  controller: controller, // Attach the controller
                  onChanged: onChanged,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                    PhoneNumberFormatter(),
                  ],
                  style: GoogleFonts.roboto(
                    fontSize: proportionalFontSize(16),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: proportionalHeight(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    String cleanText = text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.length > 4 && cleanText.length <= 7) {
      cleanText = '${cleanText.substring(0, 4)} ${cleanText.substring(4)}';
    } else if (cleanText.length > 7 && cleanText.length <= 10) {
      cleanText =
          '${cleanText.substring(0, 4)} ${cleanText.substring(4, 7)} ${cleanText.substring(7)}';
    } else if (cleanText.length > 10 && cleanText.length <= 15) {
      cleanText =
          '${cleanText.substring(0, 4)} ${cleanText.substring(4, 7)} ${cleanText.substring(7, 10)} ${cleanText.substring(10)}';
    }

    return TextEditingValue(
      text: cleanText,
      selection: TextSelection.collapsed(offset: cleanText.length),
    );
  }
}
