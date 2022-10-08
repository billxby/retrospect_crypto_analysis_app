import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;

  setLightMode() {
    currentTheme = customWhite;
    notifyListeners();
  }

  setDarkmode() {
    currentTheme = customDark;
    notifyListeners();
  }
}

ThemeData customWhite = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.white,
    onPrimary: Colors.black,
    // Colors that are not relevant to AppBar in LIGHT mode:
    primaryVariant: Colors.grey,
    secondary: Colors.black,
    onSecondary: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.grey,
    onSurface: Colors.grey,
    tertiary: Colors.white,
    secondaryVariant: Colors.black12,
    error: Colors.grey,
    onError: Colors.grey,
  )
);

ThemeData customDark = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    surface: Colors.black,
    onSurface: Colors.white,
    // Colors that are not relevant to AppBar in DARK mode:
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.black,
    background: Colors.white10,
    onBackground: Colors.white,
    secondaryVariant: Colors.white24,
    tertiary: Color(0xff1B1B1B),
    error: Colors.grey,
    onError: Colors.grey,
    inverseSurface: Colors.grey,

  ),
  // primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
);