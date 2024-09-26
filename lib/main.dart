import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(Pixadg());
}

class Pixadg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PixAdg: Images from Pixabay',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFFD7CCC8, // Beige color
          <int, Color>{
            50: Color(0xFFEFEBE9),
            100: Color(0xFFD7CCC8),
            200: Color(0xFFBCAAA4),
            300: Color(0xFFA1887F),
            400: Color(0xFF8D6E63),
            500: Color(0xFF795548),
            600: Color(0xFF6D4C41),
            700: Color(0xFF5D4037),
            800: Color(0xFF4E342E),
            900: Color(0xFF3E2723),
          },
        ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFF5F5DC), 
        ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: MaterialColor(
          0xFFD7CCC8, // Beige color
          <int, Color>{
            50: Color(0xFFEFEBE9),
            100: Color(0xFFD7CCC8),
            200: Color(0xFFBCAAA4),
            300: Color(0xFFA1887F),
            400: Color(0xFF8D6E63),
            500: Color(0xFF795548),
            600: Color(0xFF6D4C41),
            700: Color(0xFF5D4037),
            800: Color(0xFF4E342E),
            900: Color(0xFF3E2723),
          },
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 74, 48, 44),
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}