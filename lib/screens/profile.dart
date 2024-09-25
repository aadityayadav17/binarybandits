import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ProfileScreenApp());
}

class ProfileScreenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.roboto(fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField("Preferred Name", _preferredNameController),
            SizedBox(height: 16),
            buildTextField("Phone Number", _phoneNumberController,
                keyboardType: TextInputType.phone),
            SizedBox(height: 16),
            buildNumberField("Budget", _budgetController),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: buildNumberField(
                        "Body Height (CM)", _heightController)),
                SizedBox(width: 16),
                Expanded(
                    child: buildNumberField(
                        "Body Weight (KG)", _weightController)),
              ],
            ),
            SizedBox(height: 16),
            buildNumberField("Except Weight (KG)", _exceptWeightController),
            SizedBox(height: 16),
            buildLocationField("Home District", _locationController),
            SizedBox(height: 16),
            buildDropDown("Dietary Preference", dietaryPreference,
                ['Classic', 'Vegan', 'Keto'], (String? value) {
              setState(() {
                dietaryPreference = value;
              });
            }),
            SizedBox(height: 16),
            buildDropDown("Dietary Restrictions", dietaryRestrictions,
                ['None', 'Gluten-Free', 'Dairy-Free'], (String? value) {
              setState(() {
                dietaryRestrictions = value;
              });
            }),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save profile logic here
                },
                child: Text('Save', style: GoogleFonts.roboto(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.roboto(),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget buildNumberField(String labelText, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.roboto(),
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget buildLocationField(
      String labelText, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.roboto(),
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onTap: () {
        // Trigger location search here
      },
    );
  }

  Widget buildDropDown(String labelText, String? currentValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue,
          isDense: true,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.roboto()),
            );
          }).toList(),
        ),
      ),
    );
  }
}
