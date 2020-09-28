import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier, WidgetsBindingObserver {
  Brightness _theme;

  ThemeChanger() {
    WidgetsBinding.instance.addObserver(this);
    _theme = WidgetsBinding.instance.window.platformBrightness;
  }

  getTheme() => _theme;

  setTheme(Brightness theme) {
    _theme = theme;
    notifyListeners();
  }
}
