// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/task_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key); // Добавлен параметр Key

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки', style: GoogleFonts.lato()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Переключатель темы
            ListTile(
              title: Text('Темная тема', style: GoogleFonts.lato(fontSize: 18)),
              trailing: Switch(
                value: taskProvider.isDarkMode,
                onChanged: (bool value) {
                  taskProvider.toggleDarkMode(value);
                },
              ),
            ),
            const SizedBox(height: 20),
            // Выбор основного цвета
            ListTile(
              title: Text('Выберите основной цвет', style: GoogleFonts.lato(fontSize: 18)),
              trailing: CircleAvatar(
                backgroundColor: taskProvider.primaryColor,
              ),
              onTap: () {
                _showColorPicker(context, taskProvider);
              },
            ),
            const SizedBox(height: 20),
            // Дополнительные настройки могут быть добавлены здесь
            // Например, выбор шрифта, настройка уведомлений и т.д.
          ],
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
              showLabel: true,
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
