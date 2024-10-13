// lib/models/user_profile.dart
class UserProfile {
  int? id;
  double height; // в сантиметрах
  double weight; // в килограммах
  String gender; // 'male' или 'female'
  int age;

  UserProfile({
    this.id,
    required this.height,
    required this.weight,
    required this.gender,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'height': height,
      'weight': weight,
      'gender': gender,
      'age': age,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      height: map['height'],
      weight: map['weight'],
      gender: map['gender'],
      age: map['age'],
    );
  }
}
