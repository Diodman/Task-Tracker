// lib/providers/task_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  final DatabaseService _dbService = DatabaseService();
  
  // Настройки темы
  bool _isDarkMode = false;
  Color _primaryColor = Colors.blue;

  // Геттеры
  List<Task> get tasks => _tasks;
  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  TaskProvider() {
    _loadTasks();
    _loadSettings();
  }

  // Загрузка задач из базы данных
  Future<void> _loadTasks() async {
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  // Добавление новой задачи
  Future<void> addTask(Task task) async {
    await _dbService.insertTask(task);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  // Обновление существующей задачи
  Future<void> updateTask(Task task) async {
    await _dbService.updateTask(task);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  // Переключение статуса задачи (завершена/не завершена)
  Future<void> toggleTaskStatus(Task task) async {
    task.isCompleted = !task.isCompleted;
    await _dbService.updateTask(task);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  // Удаление задачи
  Future<void> deleteTask(int id) async {
    await _dbService.deleteTask(id);
    _tasks = await _dbService.getTasks();
    notifyListeners();
  }

  // Загрузка настроек темы из SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    int colorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
    _primaryColor = Color(colorValue);
    notifyListeners();
  }

  // Переключение между светлой и тёмной темами
  Future<void> toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Изменение основного цвета темы
  Future<void> changePrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', _primaryColor.value);
    notifyListeners();
  }
}
