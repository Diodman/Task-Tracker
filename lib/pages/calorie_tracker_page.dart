// lib/pages/calorie_tracker_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/task_provider.dart';
import '../models/calorie_entry.dart';
import '../models/user_profile.dart';

class CalorieTrackerPage extends StatefulWidget {
  const CalorieTrackerPage({Key? key}) : super(key: key);

  @override
  _CalorieTrackerPageState createState() => _CalorieTrackerPageState();
}

class _CalorieTrackerPageState extends State<CalorieTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  String? _food;
  double? _calories;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProfile = taskProvider.userProfile;

    double bmr = 0;
    if (userProfile != null) {
      if (userProfile.gender == 'male') {
        bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * userProfile.age + 5;
      } else {
        bmr = 10 * userProfile.weight + 6.25 * userProfile.height - 5 * userProfile.age - 161;
      }
    }

    double totalCalories = taskProvider.calorieEntries.fold(0, (sum, entry) => sum + entry.calories);
    double remainingCalories = bmr - totalCalories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Отслеживание Калорий', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/user_profile');
            },
          ),
        ],
      ),
      body: userProfile == null
          ? const Center(
              child: Text(
                'Пожалуйста, заполните ваш профиль',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Базальная метаболическая скорость (BMR): ${bmr.toStringAsFixed(2)} калорий/день',
                    style: const TextStyle(fontSize: 18),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Потреблено калорий: ${totalCalories.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 10),
                  Text(
                    'Осталось калорий: ${remainingCalories.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Еда
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Еда',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите название еды';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _food = value;
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                        const SizedBox(height: 20),
                        // Калории
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Калории',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите количество калорий';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Введите корректное число';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _calories = double.parse(value!);
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final entry = CalorieEntry(
                                food: _food!,
                                calories: _calories!,
                                date: DateTime.now(),
                              );
                              taskProvider.addCalorieEntry(entry);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Калории добавлены')),
                              );
                            }
                          },
                          child: Text('Добавить', style: GoogleFonts.lato()),
                        ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: taskProvider.calorieEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'Нет записей калорий',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: taskProvider.calorieEntries.length,
                            itemBuilder: (context, index) {
                              final entry = taskProvider.calorieEntries[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  title: Text(entry.food, style: GoogleFonts.lato()),
                                  subtitle: Text('${entry.calories} калорий'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      taskProvider.deleteCalorieEntry(entry.id!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Запись удалена')),
                                      );
                                    },
                                  ),
                                ),
                              ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: index * 100));
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
