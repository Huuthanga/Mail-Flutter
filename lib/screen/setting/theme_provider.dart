import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  bool _autoAnswerMode = false;
  double fontSize = 16.0; // Default font size
  String fontFamily = 'Roboto'; // Default font family


  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoAnswerMode => _autoAnswerMode;

  ThemeData get lightTheme => ThemeData.light().copyWith(
        primaryColor: Colors.green,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
        ),
      );

  ThemeData get darkTheme => ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
        ),
      );

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Cập nhật trạng thái
  }
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }
  void toggleAutoAnswerMode(bool enabled) {
    _autoAnswerMode = enabled;
    notifyListeners();
  }
  void setFontSize(double size) {
    fontSize = size;
    notifyListeners();
  }

  void setFontFamily(String family) {
    fontFamily = family;
    notifyListeners();
  }

  TextStyle getTextStyle() {
    return TextStyle(fontSize: fontSize, fontFamily: fontFamily);
  }
}
