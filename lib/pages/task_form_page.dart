// lib/pages/task_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;

  const TaskFormPage({Key? key, this.task}) : super(key: key); // Добавлен параметр Key

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Добавить задачу' : 'Редактировать задачу',
          style: GoogleFonts.lato(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Поле для названия задачи
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                style: GoogleFonts.lato(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Поле для описания задачи
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                style: GoogleFonts.lato(),
                onSaved: (value) {
                  _description = value ?? '';
                },
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Кнопка сохранения задачи
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.task == null) {
                      await taskProvider.addTask(Task(title: _title, description: _description));
                    } else {
                      Task updatedTask = Task(
                        id: widget.task!.id,
                        title: _title,
                        description: _description,
                        isCompleted: widget.task!.isCompleted,
                      );
                      await taskProvider.updateTask(updatedTask);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.task == null ? 'Добавить' : 'Сохранить',
                  style: GoogleFonts.lato(),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
