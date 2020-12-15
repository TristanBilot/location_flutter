import 'package:flutter/material.dart';

const LogoOrangeColor = Color(0xFFF75882); // Color.fromRGBO(241, 160, 45, 1);
const LogoPinkColor = Color(0xFFFAA767); // Color.fromRGBO(238, 88, 127, 1);

const AppGradient = LinearGradient(
  colors: [LogoOrangeColor, LogoPinkColor],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const GreenGradient = LinearGradient(
  colors: [Color(0xFF96E4DF), Color(0xFF4DCCC6)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const GoldGradient = LinearGradient(
  colors: [Color(0xFFF9D976), Color(0xFFF39F86)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const GreyGradient = LinearGradient(
  colors: [Color(0xFF9FA4C4), Color(0xFFB3CDD1)],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);

const PrimaryColor = const Color(0xFFFF4081);
const PrimaryColorLight = const Color(0xFFFF79b0);
const PrimaryColorDark = const Color(0xFFc60055);

const SecondaryColor = const Color(0xFFc51162);
const SecondaryColorLight = const Color(0xFFFd558F);
const SecondaryColorDark = const Color(0xFF8e0038);

// const Background = const Color(0xFFfffdf7);
const Background = const Color(0xFFffffff);
const TextColor = const Color(0xFF000000);
const ListBackgroundColor = const Color.fromARGB(255, 240, 240, 240);

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
      canvasColor: Colors.white, // used by BottomNavigationBar
      // cardTheme: base.cardTheme.copyWith(
      //   color: Color.fromARGB(255, 240, 240, 240),
      // ),
      textTheme: base.textTheme.copyWith(
          headline6: base.textTheme.headline6.copyWith(color: TextColor),
          headline5:
              base.textTheme.headline6.copyWith(color: Color(0xFFFFFFFF)),
          bodyText2: base.textTheme.bodyText2.copyWith(color: TextColor),
          bodyText1: base.textTheme.bodyText1.copyWith(color: TextColor)),

      /* disable the Android splash effect */
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}
