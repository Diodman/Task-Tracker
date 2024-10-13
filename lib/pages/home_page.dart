// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        title: Text('Задачи', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              color: Theme.of(context).iconTheme.color,
              width: 24,
              height: 24,
            ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/empty_tasks.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Нет задач',
                    style: TextStyle(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ).animate().fadeIn(duration: 500.ms),
                ],
              ),
            )
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OpenContainer(
                    transitionDuration: const Duration(milliseconds: 500),
                    openBuilder: (context, _) => TaskFormPage(task: task),
                    closedElevation: 0,
                    closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    closedColor: Theme.of(context).cardColor,
                    closedBuilder: (context, openContainer) => ListTile(
                      leading: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          key: ValueKey<bool>(task.isCompleted),
                          color: task.isCompleted ? Colors.green : Colors.grey,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(task.description),
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (bool? value) {
                          taskProvider.toggleTaskStatus(task);
                        },
                      ),
                      onLongPress: () {
                        _showDeleteDialog(context, taskProvider, task.id!);
                      },
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: Duration(milliseconds: index * 100));
              },
            ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => const TaskFormPage(),
        closedElevation: 6.0,
        closedShape: const CircleBorder(),
        closedColor: Theme.of(context).primaryColor,
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          child: SvgPicture.asset(
            'assets/icons/add.svg',
            color: Colors.white,
            width: 24,
            height: 24,
          ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Задача удалена')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
