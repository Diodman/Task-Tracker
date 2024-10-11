// lib/models/task.dart
class Task {
  int? id;
  String title;
  String description;
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
  });

  // Преобразование задачи в Map для базы данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Создание задачи из Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
