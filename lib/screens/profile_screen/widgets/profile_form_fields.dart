/// A widget that represents a form with various fields for user profile information.
///
/// The `ProfileFormFields` widget includes fields for name, phone number, budget, height, weight,
/// expected weight, home district, dietary preference, and dietary restrictions. Each field is
/// associated with a controller and provides callbacks for handling changes and validations.
///
/// The widget is designed to be used within a form and provides a column layout with spacing
/// between each field.
///
/// Required parameters:
/// - [nameController]: A [TextEditingController] for the name field.
/// - [phoneNumberController]: A [TextEditingController] for the phone number field.
/// - [budgetController]: A [TextEditingController] for the budget field.
/// - [heightController]: A [TextEditingController] for the height field.
/// - [weightController]: A [TextEditingController] for the weight field.
/// - [expectedWeightController]: A [TextEditingController] for the expected weight field.
/// - [homeDistrictController]: A [TextEditingController] for the home district field.
/// - [onDietaryPreferenceChanged]: A callback function that is called when the dietary preference changes.
/// - [onDietaryRestrictionsChanged]: A callback function that is called when the dietary restrictions change.
/// - [onAnyFieldChanged]: A callback function that is called when any field changes.
/// - [dietaryRestrictions]: A list of current dietary restrictions.
/// - [onNameValidated]: A callback function that is called to validate the name.
///
/// Optional parameters:
/// - [dietaryPreference]: The current dietary preference.
///
/// Example usage:
/// ```dart
/// ProfileFormFields(
///   nameController: nameController,
///   phoneNumberController: phoneNumberController,
///   budgetController: budgetController,
///   heightController: heightController,
///   weightController: weightController,
///   expectedWeightController: expectedWeightController,
///   homeDistrictController: homeDistrictController,
///   onDietaryPreferenceChanged: (value) {
///     // Handle dietary preference change
///   },
///   onDietaryRestrictionsChanged: (value) {
///     // Handle dietary restrictions change
///   },
///   onAnyFieldChanged: () {
///     // Handle any field change
///   },
///   dietaryPreference: 'Vegan',
///   dietaryRestrictions: ['Dairy', 'Nuts'],
///   onNameValidated: (value) {
///     // Validate name
///   },
/// )
/// ```
library profile_form_fields;

import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'phone_number_field.dart';
import 'budget_field.dart';
import 'height_weight_field.dart';
import 'dropdown_field.dart';
import 'multi_select_dropdown_field.dart';

class ProfileFormFields extends StatelessWidget {
  final TextEditingController nameController; // Controller for name
  final TextEditingController
      phoneNumberController; // Controller for phone number
  final TextEditingController budgetController; // Controller for budget
  final TextEditingController heightController; // Controller for height
  final TextEditingController weightController; // Controller for weight
  final TextEditingController
      expectedWeightController; // Controller for expected weight
  final TextEditingController
      homeDistrictController; // Controller for home district
  final Function(String?)
      onDietaryPreferenceChanged; // Callback for dietary preference
  final Function(List<String>)
      onDietaryRestrictionsChanged; // Callback for dietary restrictions
  final VoidCallback onAnyFieldChanged; // Callback when any field changes
  final String? dietaryPreference; // Current dietary preference
  final List<String> dietaryRestrictions; // Current dietary restrictions
  final Function(String?) onNameValidated; // Callback for name validation

  // Add controller to constructor
  const ProfileFormFields({
    super.key,
    required this.nameController,
    required this.phoneNumberController,
    required this.budgetController,
    required this.heightController,
    required this.weightController,
    required this.expectedWeightController,
    required this.homeDistrictController,
    required this.onDietaryPreferenceChanged,
    required this.onDietaryRestrictionsChanged,
    required this.onAnyFieldChanged,
    this.dietaryPreference,
    required this.dietaryRestrictions,
    required this.onNameValidated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name Field
        CustomTextField(
          labelText: "Preferred Name*",
          controller: nameController, // Attach name controller
          onChanged: (String? value) {
            onAnyFieldChanged();
            onNameValidated(value); // Validate the name on every change
          },
        ),
        const SizedBox(height: 16),

        // Phone Number Field
        PhoneNumberField(
          controller: phoneNumberController, // Attach phone number controller
          labelText: "Phone Number",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),

        // Budget Field
        BudgetField(
          controller: budgetController, // Attach budget controller
          labelText: "Budget/Week",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),

        // Height Field
        HeightWeightField(
          controller: heightController, // Attach height controller
          labelText: "Height",
          unit: "CM",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),

        // Weight Field
        HeightWeightField(
          controller: weightController, // Attach weight controller
          labelText: "Weight",
          unit: "KG",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),

        // Expected Weight Field
        HeightWeightField(
          controller:
              expectedWeightController, // Attach expected weight controller
          labelText: "Expected Weight",
          unit: "KG",
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),

        // Home District Field
        CustomTextField(
          labelText: "Home District",
          controller: homeDistrictController, // Attach home district controller
          isLocationField: true,
          onChanged: (_) => onAnyFieldChanged(),
        ),
        const SizedBox(height: 16),

        // Dietary Preference Dropdown
        DropdownField(
          labelText: "Dietary Preference",
          currentValue: dietaryPreference,
          items: const ['No Preference', 'Vegan', 'Vegetarian'],
          onChanged: (value) {
            onDietaryPreferenceChanged(value);
            onAnyFieldChanged();
          },
        ),
        const SizedBox(height: 16),

        // Dietary Restrictions Multi-Select Dropdown
        MultiSelectDropdownField(
          labelText: "Dietary Restrictions",
          items: const ['Dairy', 'Eggs', 'Fish', 'Nuts', 'Shellfish', 'Soy'],
          selectedItems: dietaryRestrictions,
          onChanged: (value) {
            onDietaryRestrictionsChanged(value);
            onAnyFieldChanged();
          },
        ),
      ],
    );
  }
}
