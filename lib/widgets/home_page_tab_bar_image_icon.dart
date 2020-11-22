import 'package:flutter/material.dart';
import 'package:location_project/widgets/home_page_tab_bar_icon.dart';

class HomePageTabBarImageIcon extends StatefulWidget {
  final bool activated;

  const HomePageTabBarImageIcon(this.activated);

  @override
  _HomePageTabBarIconState createState() => _HomePageTabBarIconState();
}

class _HomePageTabBarIconState extends State<HomePageTabBarImageIcon> {
  @override
  Widget build(BuildContext context) {
    return Tab(
      icon: Image.asset(
        widget.activated ? 'assets/logo.png' : 'assets/logo_grey.png',
        height: HomePageTabBarIcon.IconSize,
      ),
    );
  }
}
