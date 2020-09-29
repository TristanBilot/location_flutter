import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  Brightness _theme;

  ThemeNotifier() {
    _theme = WidgetsBinding.instance.window.platformBrightness;
  }

  get getTheme => _theme;
  get isDark => _theme == Brightness.dark;

  setTheme(Brightness theme) {
    _theme = theme;
    notifyListeners();
  }

  doStuff(Function ifLight, Function ifDark) {
    print(_theme.toString());
    _theme == Brightness.dark ? ifDark() : ifLight();
  }
}
