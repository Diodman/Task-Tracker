import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../notifications.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({Key? key, this.task}) : super(key: key);
  final Task? task;

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime? _deadline;
  late DateTime? _notificationTime; // Добавлено

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _deadline = widget.task?.deadline;
    _notificationTime = widget.task?.deadline?.subtract(Duration(minutes: 1)); // Напоминание за минуту по умолчанию
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Добавить задачу' : 'Редактировать задачу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Название задачи'),
                initialValue: _title,
                onSaved: (value) {
                  _title = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Описание задачи'),
                initialValue: _description,
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Срок выполнения', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _deadline = picked;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _deadline != null ? DateFormat('yyyy-MM-dd').format(_deadline!) : '',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Время напоминания', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _notificationTime != null
                        ? TimeOfDay.fromDateTime(_notificationTime!)
                        : TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _notificationTime = DateTime(
                        _deadline?.year ?? DateTime.now().year,
                        _deadline?.month ?? DateTime.now().month,
                        _deadline?.day ?? DateTime.now().day,
                        picked.hour,
                        picked.minute,
                      );
                    });
                  }
                },
                controller: TextEditingController(
                  text: _notificationTime != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(_notificationTime!)
                      : '',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Task newTask = Task(
                      title: _title,
                      description: _description,
                      deadline: _deadline,
                    );

                    if (widget.task == null) {
                      await taskProvider.addTask(newTask);
                      if (_notificationTime != null && mounted) {
                        scheduleNotification(_notificationTime!, newTask.title);
                      }
                    } else {
                      Task updatedTask = Task(
                        id: widget.task!.id,
                        title: _title,
                        description: _description,
                        isCompleted: widget.task!.isCompleted,
                        deadline: _deadline,
                      );
                      await taskProvider.updateTask(updatedTask);
                    }
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(widget.task == null ? 'Добавить' : 'Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scheduleNotification(DateTime notificationTime, String taskTitle) {
  final service = NotificationService();
  service.scheduleNotification(notificationTime, taskTitle);
}

}
