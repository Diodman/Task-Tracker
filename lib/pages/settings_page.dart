// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              leading: SvgPicture.asset(
                'assets/icons/theme.svg',
                color: Theme.of(context).iconTheme.color,
                width: 30,
                height: 30,
              ),
              title: Text('Темная тема', style: GoogleFonts.lato(fontSize: 18)),
              trailing: Switch(
                value: taskProvider.isDarkMode,
                onChanged: (bool value) {
                  taskProvider.toggleDarkMode(value);
                },
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 20),
            // Выбор основного цвета
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/color_palette.svg',
                color: Theme.of(context).iconTheme.color,
                width: 30,
                height: 30,
              ),
              title: Text('Выберите основной цвет', style: GoogleFonts.lato(fontSize: 18)),
              trailing: CircleAvatar(
                backgroundColor: taskProvider.primaryColor,
              ),
              onTap: () {
                _showColorPicker(context, taskProvider);
              },
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: 20),
            // Дополнительные настройки (например, уведомления)
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/notifications.svg',
                color: Theme.of(context).iconTheme.color,
                width: 30,
                height: 30,
              ),
              title: Text('Уведомления', style: GoogleFonts.lato(fontSize: 18)),
              trailing: Switch(
                value: true, // Здесь можно добавить функционал для управления уведомлениями
                onChanged: (bool value) {
                  // Обработчик изменения состояния
                },
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
            const SizedBox(height: 20),
            // Показать анимацию для настроек
            Expanded(
              child: Center(
                child: Animate(
                  effects: [
                    FadeEffect(duration: 500.ms, delay: 400.ms),
                   ],
                  child: Lottie.asset(
                    'assets/animations/settings.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
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
