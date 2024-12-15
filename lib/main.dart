//main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_generator/themes/dark.dart';
import 'package:recipe_generator/themes/light.dart';
import 'package:recipe_generator/themes/provider.dart';
import 'home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
    

      debugShowCheckedModeBanner: false,
      title: 'Recipe Generator App: Cibo',
      theme: lightTheme, 
      darkTheme: darkTheme, 
      themeMode: Provider.of<ThemeProvider>(context).themeMode,


      home: const Home(), 
    );
  }
}
