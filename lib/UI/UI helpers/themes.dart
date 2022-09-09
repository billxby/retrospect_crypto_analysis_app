import 'package:flutter/material.dart';

Color appBarColor = Colors.black;

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
  ),
  // primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
);