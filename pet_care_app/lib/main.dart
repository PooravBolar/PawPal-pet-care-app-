import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'home_page.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyBKTKm-bPWxS_KjEuXKcluqY-S9zNFjSyg');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawPal Care',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: HomePage(),
    );
  }
}
