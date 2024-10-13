// lib/models/calorie_entry.dart
class CalorieEntry {
  int? id;
  String food;
  double calories;
  DateTime date;

  CalorieEntry({
    this.id,
    required this.food,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food': food,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  factory CalorieEntry.fromMap(Map<String, dynamic> map) {
    return CalorieEntry(
      id: map['id'],
      food: map['food'],
      calories: map['calories'],
      date: DateTime.parse(map['date']),
    );
  }
}
