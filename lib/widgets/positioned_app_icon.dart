import 'package:flutter/material.dart';

class PositionedAppIcon extends StatefulWidget {
  PositionedAppIcon({Key key}) : super(key: key);

  @override
  _PositionedAppIconState createState() => _PositionedAppIconState();
}

class _PositionedAppIconState extends State<PositionedAppIcon> {
  final double _iconSize = 50;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - (_iconSize / 2),
      top: 70,
      child: Image.asset(
        'assets/tinder.png',
        height: 50,
        width: 50,
      ),
    );
  }
}
