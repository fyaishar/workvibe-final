// lib/main.dart
import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'pages/start_page.dart'; // ← make sure you have this page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workvibe',
      theme: AppTheme.light,          // ← your custom ThemeData
      debugShowCheckedModeBanner: false,
      home: const StartPage(),        // ← your start screen
    );
  }
}

