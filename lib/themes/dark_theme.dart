import 'package:flutter/material.dart';
import 'package:location_project/themes/light_theme.dart';

class DarkTheme {
  static final ThemeData defaultTheme = _buildTheme();
  static const PrimaryDarkColor = Color.fromRGBO(33, 33, 33, 1);
  static const BackgroundDarkColor = Color.fromRGBO(48, 48, 48, 1);

  static ThemeData _buildTheme() {
    final ThemeData base = ThemeData.dark();

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        bodyText2: base.textTheme.headline6.copyWith(color: Colors.white),
        headline5: base.textTheme.headline6.copyWith(color: TextColor),
      ),
      canvasColor: BackgroundDarkColor,
      /* disable the Android splash effect */
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}
