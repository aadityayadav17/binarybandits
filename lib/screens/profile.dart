import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? dietaryPreference = 'Classic';
  String? dietaryRestrictions = 'None';

  final TextEditingController _preferredNameController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _exceptWeightController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme, // Apply Roboto Flex font globally
        ),
      ),
      home: Scaffold(
        backgroundColor:
            const Color.fromRGBO(239, 250, 244, 1), // Updated background color
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(
              239, 250, 244, 1), // Match the background color
          elevation: 0,
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Profile heading aligned left
            children: [
              const SizedBox(height: 10),
              const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 24),

              // Centered Fields
              Center(
                  child:
                      _buildField("Preferred Name", _preferredNameController)),
              const SizedBox(height: 16),

              // Phone Number with Country Code Picker
              Center(
                  child: _buildPhoneNumberField(
                      "Phone Number", _phoneNumberController)),
              const SizedBox(height: 16),

              Center(child: _buildBudgetField("Budget", _budgetController)),
              const SizedBox(height: 16),

              Center(child: _buildHeightField("Height", _heightController)),
              const SizedBox(height: 16),

              Center(child: _buildWeightField("Weight", _weightController)),
              const SizedBox(height: 16),

              Center(
                  child: _buildWeightField(
                      "Excepted Weight", _exceptWeightController)),
              const SizedBox(height: 16),

              Center(
                  child: _buildField("Home District", _locationController,
                      isLocationField: true)),
              const SizedBox(height: 16),

              Center(
                  child: _buildDropDown("Dietary Preference", dietaryPreference,
                      ['Classic', 'Vegan', 'Vegetarian'], (String? value) {
                setState(() {
                  dietaryPreference = value;
                });
              })),
              const SizedBox(height: 16),

              Center(
                  child: _buildDropDown(
                      "Dietary Restrictions", dietaryRestrictions, [
                'None',
                'Dairy',
                'Eggs',
                'Fish',
                'Nuts',
                'Shellfish',
                'Soy'
              ], (String? value) {
                setState(() {
                  dietaryRestrictions = value;
                });
              })),
              const SizedBox(height: 24),

              // Centered Save Button
              Center(
                child: SizedBox(
                  width: 300, // Center and reduce width
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
              ),
              const SizedBox(height: 40), // Space for the floating Save button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField(
      String labelText, TextEditingController controller) {
    return Container(
      width: 300, // Adjust width of the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          const SizedBox(height: 4), // Adjust spacing between label and inputs
          Row(
            children: [
              // Country Code Picker with a Small Rectangle for Country Code
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 0), // Reduced padding
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF979797), // Border color
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: CountryCodePicker(
                  onChanged: (countryCode) {
                    setState(() {});
                  },
                  initialSelection: 'AU', // Set default country
                  favorite: ['+61', 'AU'], // Favorites
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  textStyle:
                      GoogleFonts.roboto(fontSize: 14, color: Colors.black),
                  padding:
                      EdgeInsets.zero, // No padding inside country code picker
                ),
              ),
              const SizedBox(
                  width:
                      12), // Reduced spacing between country code picker and phone number

              // Phone number input field with formatting and 15-digit limit
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(
                        15), // Limit input to 15 digits
                    _PhoneNumberFormatter(), // Custom formatter to add spaces/dashes
                  ],
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust internal padding
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Custom Budget Field with $ prefix (not inside the rectangle)
  Widget _buildBudgetField(String labelText, TextEditingController controller) {
    return Container(
      width: 300, // Adjust width of the outer container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          const SizedBox(height: 4), // Adjust spacing between label and input
          Row(
            children: [
              // $ Symbol not in a rectangle, just plain text
              Text(
                '\$', // Dollar sign
                style: GoogleFonts.roboto(
                    fontSize: 14, color: const Color(0xFF979797)),
              ),
              const SizedBox(
                  width: 8), // Small spacing between $ and input field

              // Input field for budget enclosed in a smaller rounded rectangle
              Container(
                width: 60, // Adjusted width to fit 5 digits comfortably
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF979797), // Border color
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(
                        5), // Limit input to 5 digits
                  ],
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust internal padding
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Separate height field with "CM" label on the right side, narrower input
  Widget _buildHeightField(String labelText, TextEditingController controller) {
    return Container(
      width: 300, // Adjust width of the outer container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          const SizedBox(height: 4), // Adjust spacing between label and input
          Row(
            children: [
              // Input field for height inside a rounded rectangle
              Container(
                width: 45, // Narrower width suitable for 3 digits
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF979797), // Border color
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(
                        3), // Limit input to 3 digits
                  ],
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust internal padding
                  ),
                ),
              ),
              const SizedBox(width: 8), // Space between input field and label
              // "CM" Label outside the input box on the right
              Text(
                'CM',
                style: GoogleFonts.roboto(
                    fontSize: 14, color: const Color(0xFF979797)),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Separate weight field with "KG" label on the right side, narrower input
  Widget _buildWeightField(String labelText, TextEditingController controller) {
    return Container(
      width: 300, // Adjust width of the outer container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          const SizedBox(height: 4), // Adjust spacing between label and input
          Row(
            children: [
              // Input field for weight inside a rounded rectangle
              Container(
                width: 45, // Narrower width suitable for 3 digits
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF979797), // Border color
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(
                        3), // Limit input to 3 digits
                  ],
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8), // Adjust internal padding
                  ),
                ),
              ),
              const SizedBox(width: 8), // Space between input field and label
              // "KG" Label outside the input box on the right
              Text(
                'KG',
                style: GoogleFonts.roboto(
                    fontSize: 14, color: const Color(0xFF979797)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build labeled fields like Budget, Except Weight
  Widget _buildLabeledField(
    String labelText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      width: 300, // Adjust width of the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.roboto(fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2), // Minimal padding
            ),
          ),
        ],
      ),
    );
  }

  // Method to build Body Composition with two text fields
  Widget _buildCompositionField(
      String labelText,
      TextEditingController heightController,
      TextEditingController weightController) {
    return Container(
      width: 300, // Adjust width of the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "CM",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2), // Minimal padding
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.roboto(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "KG",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2), // Minimal padding
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build the basic field with label and optional location icon
  Widget _buildField(
    String labelText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool isLocationField = false,
  }) {
    return Container(
      width: 300, // Adjust width of the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.roboto(fontSize: 16),
            decoration: InputDecoration(
              border: InputBorder.none,
              suffixIcon: isLocationField
                  ? const Icon(Icons.location_on, color: Colors.black54)
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ), // Ensure the icon is properly constrained
              contentPadding: const EdgeInsets.only(
                  top: 8, bottom: 8), // Minimal padding to align
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropDown(String labelText, String? currentValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      width: 300, // Adjust width of the container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF979797), // Custom color for labels
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              hint: Text(
                'Select Option',
                style: GoogleFonts.roboto(fontSize: 16, color: Colors.black),
              ),
              value: currentValue,
              onChanged: onChanged,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                );
              }).toList(),
              buttonStyleData: ButtonStyleData(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                width: 160,
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                iconSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom PhoneNumberFormatter to format as 'XXXX XXX XXX XXXXX'
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Remove all non-digit characters for processing
    String cleanText = text.replaceAll(RegExp(r'\D'), '');

    // Format the cleaned text into groups of 4, 3, 3, and 5 digits
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
