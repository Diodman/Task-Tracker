// lib/pages/user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/task_provider.dart';
import '../models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key); // Добавлен параметр Key

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  double? _height;
  double? _weight;
  String? _gender;
  int? _age;

  @override
  void initState() {
    super.initState();
    final userProfile = Provider.of<TaskProvider>(context, listen: false).userProfile;
    if (userProfile != null) {
      _height = userProfile.height;
      _weight = userProfile.weight;
      _gender = userProfile.gender;
      _age = userProfile.age;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль', style: GoogleFonts.lato()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Добавлен для предотвращения переполнения
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Анимация профиля
                Center(
                  child: Animate(
                    effects: [
                      FadeEffect(duration: 500.ms, delay: 100.ms),
                    ],
                    child: Lottie.asset(
                      'assets/animations/profile.json',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Рост
                TextFormField(
                  initialValue: _height != null ? _height.toString() : '',
                  decoration: const InputDecoration(
                    labelText: 'Рост (см)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите ваш рост';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите корректное число';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _height = double.parse(value!);
                  },
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms),
                const SizedBox(height: 20),
                // Вес
                TextFormField(
                  initialValue: _weight != null ? _weight.toString() : '',
                  decoration: const InputDecoration(
                    labelText: 'Вес (кг)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите ваш вес';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Введите корректное число';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _weight = double.parse(value!);
                  },
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms),
                const SizedBox(height: 20),
                // Пол
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Пол',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text('Мужской'),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text('Женский'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Выберите ваш пол';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _gender = value;
                  },
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 20),
                // Возраст
                TextFormField(
                  initialValue: _age != null ? _age.toString() : '',
                  decoration: const InputDecoration(
                    labelText: 'Возраст',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите ваш возраст';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Введите корректное число';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = int.parse(value!);
                  },
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 500.ms),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final profile = UserProfile(
                        height: _height!,
                        weight: _weight!,
                        gender: _gender!,
                        age: _age!,
                      );
                      taskProvider.setUserProfile(profile);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Профиль обновлён')),
                      );
                    }
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/save.svg',
                    color: Colors.white,
                    width: 24,
                    height: 24,
                  ),
                  label: Text('Сохранить', style: GoogleFonts.lato()),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, TaskProvider provider) {
    Color tempColor = provider.primaryColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Выберите цвет', style: GoogleFonts.lato()),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              labelTypes: const [], // Заменено на labelTypes с пустым списком
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Отмена', style: GoogleFonts.lato()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Выбрать', style: GoogleFonts.lato()),
              onPressed: () {
                provider.changePrimaryColor(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
