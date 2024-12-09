import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import

void main() {
  runApp(
    ProviderScope(
      // Wrap MyApp with ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Use the SplashScreen widget
    );
  }
}
