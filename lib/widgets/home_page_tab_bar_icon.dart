import 'package:flutter/material.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/widgets/gradient_icon.dart';

class HomePageTabBarIcon extends StatefulWidget {
  static const IconSize = 26.0;
  static const UnactivatedColor = Color.fromRGBO(189, 187, 183, 1);
  final IconData icon;
  final bool activated;

  const HomePageTabBarIcon(this.icon, this.activated);

  @override
  _HomePageTabBarIconState createState() => _HomePageTabBarIconState();
}

class _HomePageTabBarIconState extends State<HomePageTabBarIcon> {
  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: GradientIcon(
        widget.icon,
        HomePageTabBarIcon.IconSize,
        widget.activated
            ? AppGradient
            : LinearGradient(colors: [
                HomePageTabBarIcon.UnactivatedColor,
                HomePageTabBarIcon.UnactivatedColor
              ]),
      ),
    );
  }
}
