# binarybandits

# EatEasy

## 1. Install Flutter SDK

First, ensure that Flutter is installed on your system:
Download Flutter SDK from the official Flutter website: flutter.dev

Extract the zip file to the desired location on your system.
Add the flutter/bin directory to your system's environment PATH.

    Windows: Update environment variables.
    macOS/Linux: Add the following to your shell configuration file (.bashrc, .zshrc, etc.):

            export PATH="$PATH:[PATH_TO_FLUTTER_DIRECTORY]/flutter/bin"

## 2. Install an Editor

Install an editor such as Visual Studio Code (VSCode) or Android Studio for coding in Flutter. Ensure that you install the required Flutter and Dart plugins:

For VSCode:
Go to the Extensions tab and install the Flutter and Dart plugins.

For Android Studio:
Go to File > Settings > Plugins and install both the Flutter and Dart plugins.

## 3. Install Android SDK

Install Android SDK and set it up in Android Studio:
Open Android Studio, go to File > Settings > Appearance & Behavior > System Settings > Android SDK.
Install the required SDK platforms and system images.
Add the path to your SDK directory in Flutter settings (if not detected automatically).

## 4. Open the Project in the IDE

Extract the attached project zip file into desired location.
Open the extracted project in VSCode, Android Studio, or another code editor by choosing the File > Open option and navigating to the project folder.

Check the pubspec.yaml file: It contains dependencies that the project needs. Once opened, the IDE may prompt you to run flutter pub get to install the dependencies.

Alternatively, run this manually via the terminal inside the project directory:

        flutter pub get

## 5. Run the Project

Now you are ready to run the Flutter project on your device.

Connect a physical device or start an Android/iOS emulator.
Run the following command in the terminal:

        flutter run

### Mock Account

If you don't want to sign up, you can use the following mock account to log in:

- Email ID: binarybandits6@gmail.com
- Password: abc123

### External dependencies

The code relies on the following dependencies:
Firebase Core (firebase_core) – Initializes Firebase within the Flutter app.

    Firebase Authentication (firebase_auth) – Provides authentication methods like email/password and third-party sign-in with Firebase.

    Firebase Realtime Database (firebase_database) – Enables interaction with Firebase Realtime Database for data storage and retrieval.

    Google Fonts (google_fonts) – Allows the use of Google Fonts in the app.

    Country Code Picker (country_code_picker) – Provides a country code selection widget for phone numbers.

    Dropdown Button 2 (dropdown_button2) – Enhanced version of the dropdown button widget with more customization options.

    Shared Preferences (shared_preferences) – Allows persistent local storage of simple key-value pairs across app sessions.

    Url Launcher (url_launcher) - Enables the app to open URLs in the device's web browser or trigger other app functionalities like making phone calls or sending emails.

##### NOTE: You do not have to setup/manage any external dependecies manually, step 4 would set them up for you.

#### References

    Images Used on Home Screen:
    - `assets/images/home_screen/discover-recipe.png` - Designed by [Freepik](https://www.freepik.com/free-photo/top-view-pasta-waffles-with-copy-space_7087845.htm#fromView=search&page=1&position=27&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895)
    - `assets/images/home_screen/grocery-list.png` - Designed by [Freepik](https://www.freepik.com/free-photo/lime-near-roasted-meat-salad_1488613.htm#fromView=search&page=1&position=28&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895)
    - `assets/images/home_screen/recipe-collection.png` - Designed by [Freepik](https://www.freepik.com/free-photo/buddha-bowl-dish-with-chicken-fillet-rice-red-cabbage-carrot-fresh-lettuce-salad-sesame_7537371.htm#fromView=search&page=4&position=44&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895)
    - `assets/images/home_screen/recipe-history.png` - Designed by [Freepik](https://www.freepik.com/free-photo/copy-space-bowl-with-salad_7763035.htm#fromView=search&page=2&position=5&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895)
    - `assets/images/home_screen/weekly-menu.png` - Designed by [Freepik](https://www.freepik.com/free-photo/flat-lay-batch-cooking-assortment-with-copy-space_11273706.htm#fromView=search&page=3&position=28&uuid=7c2ca182-9b25-4bfc-9ecd-2dfadbbbf895)

    Icons Used in the Application:
    - Uicons by [Flaticon](https://www.flaticon.com/uicons)

    Recipes Generated Using:
    - These recipes were created with the assistance of GPT-4.

    Recipe Images Generated Using:
    - These images were created with the assistance of DALL·E 3.

    Ingredient Matching:
    - Ingredients were matched with products using OpenAI's GPT-4 model (version gpt-4-2024-08-06).

    Products for Grocery List:
    - Products from Aldi: [Aldi Data](https://github.com/donde-esta-la-biblioteca/Woolworths-Coles-IGA/blob/ae34ea19d32bb9568f87bf29b13aeeec55d2e0a7/1.%20Cleaned%20Data/Aldi.csv)
    - Products from Coles: [Coles Data](https://github.com/donde-esta-la-biblioteca/Woolworths-Coles-IGA/blob/ae34ea19d32bb9568f87bf29b13aeeec55d2e0a7/1.%20Cleaned%20Data/Coles.csv)
    - Products from Woolworths: [Woolworths Data](https://github.com/donde-esta-la-biblioteca/Woolworths-Coles-IGA/blob/ae34ea19d32bb9568f87bf29b13aeeec55d2e0a7/1.%20Cleaned%20Data/Woolworths.csv)

##### NOTE: The app experience is better suited for mobile devices, specifically iOS and Android.
