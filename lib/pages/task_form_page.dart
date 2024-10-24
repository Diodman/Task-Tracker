import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Добавьте импорт
import '../models/task.dart'; // Замените на свой путь
import '../providers/task_provider.dart'; // Замените на свой путь
import '../notifications.dart'; // Импортируйте файл с настройкой уведомлений

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({Key? key, this.task}) : super(key: key); // Добавлено const
  final Task? task;

  @override
  _TaskFormPageState createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime? _deadline; // Добавлено для хранения даты
  late TimeOfDay? _timeOfDay; // Добавлено для хранения времени

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _deadline = widget.task?.deadline; // Инициализация даты из задачи
    _timeOfDay = _deadline != null ? TimeOfDay.fromDateTime(_deadline!) : null; // Инициализация времени
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context); // Получение taskProvider
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Добавить задачу' : 'Редактировать задачу',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Поле для выбора даты
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Дата выполнения',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _deadline = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _deadline != null ? DateFormat('yyyy-MM-dd').format(_deadline!) : '',
                ),
              ),

              // Поле для выбора времени
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Время выполнения',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _timeOfDay ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _timeOfDay = pickedTime;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _timeOfDay != null ? _timeOfDay!.format(context) : '',
                ),
              ),

              // Остальные поля формы для задачи
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

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Объединение даты и времени в один объект DateTime
                    DateTime? finalDateTime;
                    if (_deadline != null && _timeOfDay != null) {
                      finalDateTime = DateTime(
                        _deadline!.year,
                        _deadline!.month,
                        _deadline!.day,
                        _timeOfDay!.hour,
                        _timeOfDay!.minute,
                      );
                    }

                    Task newTask = Task(
                      title: _title,
                      description: _description,
                      deadline: finalDateTime,
                    );

                    if (widget.task == null) {
                      await taskProvider.addTask(newTask);
                      if (finalDateTime != null && mounted) { // Проверка mounted
                        scheduleNotification(finalDateTime, newTask.title);
                      }
                    } else {
                      Task updatedTask = Task(
                        id: widget.task!.id,
                        title: _title,
                        description: _description,
                        isCompleted: widget.task!.isCompleted,
                        deadline: finalDateTime,
                      );
                      await taskProvider.updateTask(updatedTask);
                    }
                    if (mounted) { // Проверка mounted
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

  // Добавьте метод для планирования уведомления
  void scheduleNotification(DateTime deadline, String taskTitle) {
    NotificationService().scheduleNotification(deadline, taskTitle); // Убедитесь, что у вас есть NotificationService
  }
}
