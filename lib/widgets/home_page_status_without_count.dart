import 'package:flutter/material.dart';
import 'package:location_project/themes/light_theme.dart';

class HomePageStatusWithoutCount extends StatelessWidget {
  const HomePageStatusWithoutCount();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      width: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradient),
    );
  }
}
