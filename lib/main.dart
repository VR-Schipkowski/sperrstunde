import 'package:flutter/material.dart';
import 'package:sperrstunde/widgets/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme(
      primary: Color(0xFFFF5F1F), // Primary color
      primaryFixed: Color(0xFFD94E1A), // Darker shade of primary color
      secondary: Color(0xFF38A3C4), // Secondary color
      secondaryFixed: Color(0xFF2E8BA8), // Darker shade of secondary color
      surface: Colors.white, // Surface color
      error: Colors.red, // Error color
      onPrimary: Colors.white, // Text color on primary color
      onSecondary: Colors.white, // Text color on secondary color
      onSurface: Colors.black, // Text color on surface color
      onError: Colors.white, // Text color on error color
      brightness: Brightness.light, // Brightness (light or dark)
    );

    return MaterialApp(
      title: 'Sperrstunde',
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: TextTheme(
          headlineSmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface),
          bodySmall: TextStyle(fontSize: 12, color: colorScheme.onSurface),
          headlineMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface),
          bodyMedium: TextStyle(fontSize: 16, color: colorScheme.onSurface),
        ),
      ),
      home: HomePage(),
    );
  }
}
