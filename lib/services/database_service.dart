// lib/services/database_service.dart
import 'dart:io'; // Для определения платформы
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Импортируем sqflite_common_ffi
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../models/calorie_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('task_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // Создание таблицы tasks
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        isCompleted INTEGER,
        date TEXT
      )
    ''');

    // Создание таблицы user_profile
    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        height REAL,
        weight REAL,
        gender TEXT,
        age INTEGER
      )
    ''');

    // Создание таблицы calorie_entry
    await db.execute('''
      CREATE TABLE calorie_entry(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food TEXT,
        calories REAL,
        date TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Если нужно добавить новые таблицы или поля в будущем
    }
    if (oldVersion < 3) {
      // Пример обновления до версии 3
      await db.execute('''
        CREATE TABLE IF NOT EXISTS calorie_entry(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          food TEXT,
          calories REAL,
          date TEXT
        )
      ''');
    }
  }

  // Методы для задач (tasks)

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks');

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Методы для профиля пользователя (UserProfile)

  Future<void> insertUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert('user_profile', profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', limit: 1);

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    final db = await database;
    await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // Методы для записей калорий (CalorieEntry)

  Future<List<CalorieEntry>> getCalorieEntries() async {
    final db = await database;
    final maps = await db.query('calorie_entry');

    return maps.map((map) => CalorieEntry.fromMap(map)).toList();
  }

  Future<void> insertCalorieEntry(CalorieEntry entry) async {
    final db = await database;
    await db.insert('calorie_entry', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteCalorieEntry(int id) async {
    final db = await database;
    await db.delete(
      'calorie_entry',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
