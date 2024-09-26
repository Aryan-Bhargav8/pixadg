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
        primarySwatch: Colors.blue,
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}