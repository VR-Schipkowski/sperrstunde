import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sperrstunde/widgets/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme lightColorScheme = ColorScheme(
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
      shadow: Color(0xFFFFB496),
      brightness: Brightness.light, // Brightness (light or dark)
    );

    final ColorScheme darkColorScheme = ColorScheme(
      primary: Color(0xFFFF5F1F), // Primary color
      primaryContainer: Color(0xFFD94E1A), // Darker shade of primary color
      secondary: Color(0xFF38A3C4), // Secondary color
      secondaryContainer: Color(0xFF2E8BA8), // Darker shade of secondary color
      surface: Color(0xFF121212), // Surface color
      error: Color(0xFFCF6679), // Error color
      onPrimary: Colors.black, // Text color on primary color
      onSecondary: Colors.black, // Text color on secondary color
      onSurface: Colors.white, // Text color on surface color
      onError: Colors.black, // Text color on error color
      brightness: Brightness.dark,
      shadow: Color(0xFFFFB496), // Brightness (light or dark)
    );

    final TextTheme baseTextTheme = TextTheme(
      headlineSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(fontSize: 12),
      headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    );
    final themeProvider = ThemeProvider(); // Define themeProvider

    return MaterialApp(
      title: 'Sperrstunde',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        textTheme: baseTextTheme.apply(
          bodyColor: lightColorScheme.onSurface,
          displayColor: lightColorScheme.onSurface,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        textTheme: baseTextTheme.apply(
          bodyColor: darkColorScheme.onSurface,
          displayColor: darkColorScheme.onSurface,
        ),
      ),
      home: HomePage(),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
