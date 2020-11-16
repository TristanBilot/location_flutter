import 'package:flutter/material.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/widgets/textSF.dart';

class TabPageStatusWithCount extends StatelessWidget {
  final int nbElements;

  TabPageStatusWithCount(this.nbElements);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradient,
            // border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        TextSF(
          '$nbElements',
          color: Colors.white,
          fontSize: 11,
        ),
      ],
    );
  }
}
