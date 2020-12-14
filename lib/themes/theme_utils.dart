import 'package:flutter/material.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';

class ThemeUtils {
  static Color getTabColor(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark
        ? Theme.of(context).primaryColor
        : Theme.of(context).backgroundColor;
  }

  static Color getListBackgroundColor(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? DarkTheme.BackgroundDarkColor : ListBackgroundColor;
  }

  static Color getBlackIfLightAndWhiteIfDark(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }

  static getResponsiveGradient(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (isDark)
      return LinearGradient(
          colors: [DarkTheme.BackgroundDarkColor, DarkTheme.PrimaryDarkColor]);
    return AppGradient;
  }
}
