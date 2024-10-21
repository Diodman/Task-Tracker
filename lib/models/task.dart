class Task {
  int? id;
  String title;
  String description;
  bool isCompleted;
  DateTime date; // Дата создания
  DateTime? deadline; // Срок выполнения (добавлено)

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? date,
    this.deadline, // Добавлено
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date.toIso8601String(),
      'deadline': deadline?.toIso8601String(), // Добавлено
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      date: DateTime.parse(map['date']),
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null, // Добавлено
    );
  }
}
