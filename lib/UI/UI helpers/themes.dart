import 'package:flutter/material.dart';

ThemeData customWhite = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.white,
    onPrimary: Colors.black,
    // Colors that are not relevant to AppBar in LIGHT mode:
    primaryVariant: Colors.grey,
    secondary: Colors.grey,
    secondaryVariant: Colors.grey,
    onSecondary: Colors.grey,
    background: Colors.grey,
    onBackground: Colors.grey,
    surface: Colors.grey,
    onSurface: Colors.grey,
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
    primary: Colors.blue,
    onPrimary: Colors.blue,
    secondary: Colors.blue,
    onSecondary: Colors.blue,
    background: Colors.grey,
    onBackground: Colors.grey,
    error: Colors.grey,
    onError: Colors.grey,
    inverseSurface: Colors.grey,

  ),
  // primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
);