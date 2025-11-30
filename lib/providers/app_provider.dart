import 'package:flutter/material.dart';
import '../models/app_settings.dart';

class AppProvider with ChangeNotifier {
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    notifyListeners();
  }

  void updateThemeColor(String color) {
    _settings = _settings.copyWith(themeColor: color);
    notifyListeners();
  }

  void updateDailyGoal(int goal) {
    _settings = _settings.copyWith(dailyGoal: goal);
    notifyListeners();
  }

  void updateFontSize(int size) {
    _settings = _settings.copyWith(fontSize: size);
    notifyListeners();
  }

  void toggleConfetti() {
    _settings = _settings.copyWith(showConfetti: !_settings.showConfetti);
    notifyListeners();
  }

  // Tema renklerini getir
  Color get primaryColor {
    switch (_settings.themeColor) {
      case 'blue':
        return Colors.blue.shade700;
      case 'green':
        return Colors.green.shade700;
      case 'purple':
        return Colors.purple.shade700;
      case 'orange':
        return Colors.orange.shade700;
      case 'red':
        return Colors.red.shade700;
      default: // indigo
        return Colors.indigo.shade700;
    }
  }

  Color get secondaryColor {
    switch (_settings.themeColor) {
      case 'blue':
        return Colors.blue.shade500;
      case 'green':
        return Colors.green.shade500;
      case 'purple':
        return Colors.purple.shade500;
      case 'orange':
        return Colors.orange.shade500;
      case 'red':
        return Colors.red.shade500;
      default: // indigo
        return Colors.purple.shade600;
    }
  }

  // Metin stilini getir
  TextStyle get bodyTextStyle {
    return TextStyle(fontSize: _settings.fontSize.toDouble());
  }

  TextStyle get titleTextStyle {
    return TextStyle(
      fontSize: (_settings.fontSize + 4).toDouble(),
      fontWeight: FontWeight.bold,
    );
  }
}
