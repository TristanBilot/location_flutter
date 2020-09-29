import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  Brightness _theme;

  ThemeNotifier() {
    _theme = WidgetsBinding.instance.window.platformBrightness;
  }

  getTheme() => _theme;

  setTheme(Brightness theme) {
    _theme = theme;
    notifyListeners();
  }
}
