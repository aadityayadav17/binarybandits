import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/profile_form_fields.dart';
import 'widgets/save_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? dietaryPreference = 'Classic';
  List<String> dietaryRestrictions = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.robotoFlexTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(239, 250, 244, 1),
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(239, 250, 244, 1),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileFormFields(
                      onDietaryPreferenceChanged: (value) {
                        setState(() {
                          dietaryPreference = value;
                        });
                      },
                      onDietaryRestrictionsChanged: (value) {
                        setState(() {
                          dietaryRestrictions = value;
                        });
                      },
                      dietaryPreference: dietaryPreference,
                      dietaryRestrictions: dietaryRestrictions,
                    ),
                    const SizedBox(height: 24),
                    const SaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
