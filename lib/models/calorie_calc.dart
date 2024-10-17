/// A Flutter application for calculating calorie and protein requirements based on user input.
///
/// The application consists of the following main components:
/// - `CalorieCalculatorApp`: The main application widget.
/// - `CalorieCalculatorScreen`: A stateful widget that provides the UI for user input and displays the calculated results.
/// - `CalorieCalculatorScreenState`: The state class for `CalorieCalculatorScreen` that handles user input and performs the calculations.
///
/// The application allows users to input their height, weight, age, gender, goal (lose weight, gain weight, maintain), and dietary preference (normal, vegetarian, vegan).
/// Based on the input, it calculates the daily calorie and protein requirements using the Harris-Benedict formula for BMR (Basal Metabolic Rate) and adjusts the values based on the selected goal and dietary preference.
///
/// The main methods and properties include:
/// - `calculateRequirements()`: A method that performs the calculations for calorie and protein requirements based on user input.
/// - `heightController`, `weightController`, `ageController`: Text editing controllers for capturing user input.
/// - `selectedGender`, `selectedGoal`, `selectedDietaryPreference`: Variables to store the selected options for gender, goal, and dietary preference.
/// - `calories`, `protein`: Variables to store the calculated calorie and protein requirements.
/// - `goals`, `dietaryPreferences`, `genders`: Lists of options for goals, dietary preferences, and genders.
///
/// The UI consists of text fields for height, weight, and age input, dropdown menus for selecting gender, goal, and dietary preference, and a button to trigger the calculation.
/// The calculated results are displayed below the button if the input is valid.
library calorie_calculator;

import 'package:flutter/material.dart';

void main() {
  runApp(CalorieCalculatorApp());
}

class CalorieCalculatorApp extends StatelessWidget {
  const CalorieCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie and Protein Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalorieCalculatorScreen(),
    );
  }
}

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  CalorieCalculatorScreenState createState() => CalorieCalculatorScreenState();
}

class CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String selectedGender = 'Male';
  String selectedGoal = 'Lose weight';
  String selectedDietaryPreference = 'Normal';

  double calories = 0;
  double protein = 0;

  final List<String> goals = ['Lose weight', 'Gain weight', 'Maintain'];
  final List<String> dietaryPreferences = ['Normal', 'Vegetarian', 'Vegan'];
  final List<String> genders = ['Male', 'Female'];

  // Method to calculate calorie and protein requirements based on user input
  void calculateRequirements() {
    double height = double.tryParse(heightController.text) ?? 0;
    double weight = double.tryParse(weightController.text) ?? 0;
    int age = int.tryParse(ageController.text) ?? 0;

    if (height == 0 || weight == 0 || age == 0) {
      return; // Invalid input
    }

    // BMR Calculation (using Harris-Benedict formula)
    if (selectedGender == 'Male') {
      calories = 88.362 + (15 * weight) + (5 * height) - (5.677 * age);
    } else {
      calories = 447.593 + (12 * weight) + (3.5 * height) - (4.330 * age);
    }

    // Adjust calorie requirement based on the goal
    if (selectedGoal == 'Lose weight') {
      calories -= 500; // Calorie deficit for weight loss
    } else if (selectedGoal == 'Gain weight') {
      calories += 500; // Calorie surplus for weight gain
    }

    // Protein requirement calculation (example)
    if (selectedGoal == 'Lose weight') {
      protein = weight * 1.8; // Higher protein intake during weight loss
    } else if (selectedGoal == 'Gain weight') {
      protein = weight * 1.6; // Moderate protein intake during weight gain
    } else {
      protein = weight * 1.2; // Maintenance protein intake
    }

    // Adjust protein and calories based on dietary preference
    if (selectedDietaryPreference == 'Vegetarian') {
      protein *= 0.9; // Assume slightly lower protein intake for vegetarians
    } else if (selectedDietaryPreference == 'Vegan') {
      protein *= 0.85; // Assume lower protein intake for vegans
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie and Protein Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
              ),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
              ),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue!;
                });
              },
              items: genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              isExpanded: true,
              hint: Text("Select Gender"),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedGoal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedGoal = newValue!;
                });
              },
              items: goals.map((String goal) {
                return DropdownMenuItem<String>(
                  value: goal,
                  child: Text(goal),
                );
              }).toList(),
              isExpanded: true,
              hint: Text("Select Goal"),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedDietaryPreference,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDietaryPreference = newValue!;
                });
              },
              items: dietaryPreferences.map((String preference) {
                return DropdownMenuItem<String>(
                  value: preference,
                  child: Text(preference),
                );
              }).toList(),
              isExpanded: true,
              hint: Text("Select Dietary Preference"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateRequirements,
              child: Text('Calculate'),
            ),
            SizedBox(height: 20),
            if (calories > 0 && protein > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Calorie Requirement: ${calories.toStringAsFixed(0)} kcal'),
                  Text(
                      'Protein Requirement: ${protein.toStringAsFixed(1)} grams'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
