import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracker/notifications.dart'; // Импортируйте файл с уведомлениями
import 'providers/task_provider.dart';
import 'pages/home_page.dart';
import 'pages/calorie_tracker_page.dart';
import 'pages/calendar_page.dart';
import 'pages/settings_page.dart';
import 'pages/user_profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService(); // Инициализируйте уведомления
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
  const TaskTrackerApp({Key? key}) : super(key: key);

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
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primarySwatch: createMaterialColor(taskProvider.primaryColor),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Colors.white),
          checkColor: MaterialStateProperty.all(Colors.black),
        ),
        useMaterial3: true,
      ),
      themeMode: taskProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainPage(),
      routes: {
        '/user_profile': (context) => const UserProfilePage(),
      },
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
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

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final NotificationService _notificationService = NotificationService();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CalorieTrackerPage(),
    CalendarPage(),
    SettingsPage(),
    UserProfilePage(),
  ];

  Future<void> _selectDateTime(BuildContext context, String taskTitle) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        final DateTime scheduledDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Запланировать уведомление
        _notificationService.scheduleNotification(scheduledDateTime, taskTitle);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Уведомление запланировано!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Калории',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Календарь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
