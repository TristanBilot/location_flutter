import 'package:flutter/material.dart';

const PrimaryColor = const Color(0xFFFF4081);
const PrimaryColorLight = const Color(0xFFFF79b0);
const PrimaryColorDark = const Color(0xFFc60055);

const SecondaryColor = const Color(0xFFc51162);
const SecondaryColorLight = const Color(0xFFFd558F);
const SecondaryColorDark = const Color(0xFF8e0038);

const Background = const Color(0xFFfffdf7);
const TextColor = const Color(0xFF000000);

class LightTheme {
  static final ThemeData defaultTheme = _buildTheme();

  static ThemeData _buildTheme() {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      accentColor: SecondaryColor,
      accentColorBrightness: Brightness.dark,
      primaryColor: PrimaryColor,
      primaryColorDark: PrimaryColorDark,
      primaryColorLight: PrimaryColorLight,
      primaryColorBrightness: Brightness.dark,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: SecondaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      scaffoldBackgroundColor: Background,
      cardColor: Background,
      textSelectionColor: PrimaryColorLight,
      backgroundColor: Background,
      canvasColor: Color.fromARGB(255, 240, 240, 240),
      // cardTheme: base.cardTheme.copyWith(
      //   color: Color.fromARGB(255, 240, 240, 240),
      // ),
      textTheme: base.textTheme.copyWith(
          headline6: base.textTheme.headline6.copyWith(color: TextColor),
          bodyText2: base.textTheme.bodyText2.copyWith(color: TextColor),
          bodyText1: base.textTheme.bodyText1.copyWith(color: TextColor)),

      /* disable the Android splash effect */
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}
