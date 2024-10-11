// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/task_provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const TaskTrackerApp(),
    ),
  );
}

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({Key? key}) : super(key: key); // Добавлен параметр Key

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return MaterialApp(
      title: 'Task Tracker',
      theme: ThemeData(
        primarySwatch: createMaterialColor(taskProvider.primaryColor),
        brightness: Brightness.light,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: createMaterialColor(taskProvider.primaryColor),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Устанавливаем фон для Scaffold
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        iconTheme: IconThemeData(color: Colors.white), // Белые иконки
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Colors.white),
          checkColor: MaterialStateProperty.all(Colors.black),
        ),
      ),
      themeMode: taskProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }

  // Функция для создания MaterialColor из обычного Color
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
