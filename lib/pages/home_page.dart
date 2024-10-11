// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_form_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key); // Добавлен параметр Key

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Tracker', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: taskProvider.tasks.isEmpty
          ? Center(
              child: Text(
                'Нет задач',
                style: const TextStyle(fontSize: 24),
              ).animate().fadeIn(duration: 500.ms),
            )
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: task.isCompleted ? Colors.green : Colors.grey,
                      size: 30,
                    ).animate().shake(delay: const Duration(milliseconds: 300)),
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.none, // Убрана условная линия, анимация применяется к виджету
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    subtitle: Text(task.description),
                    trailing: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        taskProvider.toggleTaskStatus(task);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskFormPage(task: task),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showDeleteDialog(context, taskProvider, task.id!);
                    },
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: index * 100));
              },
            ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => const TaskFormPage(),
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          child: const Icon(Icons.add),
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  void _showDeleteDialog(BuildContext context, TaskProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить задачу', style: GoogleFonts.lato()),
          content: Text('Вы уверены, что хотите удалить эту задачу?', style: GoogleFonts.lato()),
          actions: [
            TextButton(
              child: Text('Отмена', style: GoogleFonts.lato()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Удалить', style: GoogleFonts.lato(color: Colors.red)),
              onPressed: () {
                provider.deleteTask(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
