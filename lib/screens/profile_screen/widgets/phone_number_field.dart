/// A custom widget that provides a phone number input field with country code picker.
///
/// The `PhoneNumberField` widget is a stateless widget that includes a text field for
/// phone number input and a country code picker. It also formats the phone number input
/// according to specified rules.
///
/// The widget takes the following parameters:
/// - `labelText`: A string that represents the label text for the input field.
/// - `controller`: A `TextEditingController` to manage the phone number input.
/// - `onChanged`: A callback function that is called whenever the phone number input changes.
///
/// The widget uses the `CountryCodePicker` package to provide a country code picker
/// and the `google_fonts` package to apply custom fonts.
///
/// Example usage:
/// ```dart
/// PhoneNumberField(
///   labelText: 'Phone Number',
///   controller: _phoneController,
///   onChanged: (value) {
///     // Handle phone number change
///   },
/// )
/// ```
///
/// The `PhoneNumberFormatter` class is a custom `TextInputFormatter` that formats
/// the phone number input by adding spaces at appropriate positions.
///
/// The formatting rules are:
/// - If the input length is greater than 4 and less than or equal to 7, a space is added after the 4th digit.
/// - If the input length is greater than 7 and less than or equal to 10, spaces are added after the 4th and 7th digits.
/// - If the input length is greater than 10 and less than or equal to 15, spaces are added after the 4th, 7th, and 10th digits.
library phone_number_field;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';

class PhoneNumberField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller; // Controller to manage phone input
  final Function(String) onChanged;

  // Add controller to constructor
  const PhoneNumberField({
    super.key,
    required this.labelText,
    required this.controller, // Pass the controller as a required parameter
    required this.onChanged,
  });

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

// Custom formatter to format phone number input
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
