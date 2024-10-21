// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../models/calorie_entry.dart';
import '../models/event.dart'; // Добавлен импорт класса Event
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseService _dbService = DatabaseService();

  // Настройки темы
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;

  // Профиль пользователя
  UserProfile? _userProfile;

  // Записи калорий
  List<CalorieEntry> _calorieEntries = [];

  // Геттеры
  List<Task> get tasks => _tasks;
  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  UserProfile? get userProfile => _userProfile;
  List<CalorieEntry> get calorieEntries => _calorieEntries;

  TaskProvider() {
    _loadTasks();
    _loadSettings();
    _loadUserProfile();
    loadCalorieEntries();
  }

  // Методы для задач (tasks)

  Future<void> _loadTasks() async {
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbService.insertTask(task);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _dbService.updateTask(task);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  Future<void> toggleTaskStatus(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _dbService.updateTask(task);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _dbService.deleteTask(id);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  // Методы для профиля пользователя (UserProfile)

  Future<void> _loadUserProfile() async {
    _userProfile = await _dbService.getUserProfile();
    notifyListeners();
  }

  Future<void> setUserProfile(UserProfile profile) async {
    await _dbService.insertUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _dbService.updateUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  // Методы для записей калорий (CalorieEntry)

  Future<void> loadCalorieEntries() async {
    _calorieEntries = await _dbService.getCalorieEntries();
    notifyListeners();
  }

  Future<void> addCalorieEntry(CalorieEntry entry) async {
    await _dbService.insertCalorieEntry(entry);
    _calorieEntries = await _dbService.getCalorieEntries();
    notifyListeners();
  }

  Future<void> deleteCalorieEntry(int id) async {
    await _dbService.deleteCalorieEntry(id);
    _calorieEntries = await _dbService.getCalorieEntries();
    notifyListeners();
  }

  // Методы для настроек темы

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    int colorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
    _primaryColor = Color(colorValue);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> changePrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', _primaryColor.value);
    notifyListeners();
  }

  // Метод для получения событий календаря
  List<Event> getEventsForDay(DateTime day) {
    List<Event> events = [];

    // Добавляем задачи
    for (var task in _tasks) {
      if (isSameDay(task.date, day)) {
        events.add(Event(title: task.title, date: day));
      }
    }

    // Добавляем записи калорий
    for (var entry in _calorieEntries) {
      if (isSameDay(entry.date, day)) {
        events.add(Event(title: '${entry.food} - ${entry.calories} калорий', date: day));
      }
    }

    return events;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}