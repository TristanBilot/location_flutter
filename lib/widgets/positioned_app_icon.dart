import 'package:flutter/material.dart';

class PositionedAppIcon extends StatefulWidget {
  final TabController _tabController;
  final int _initialIndex;

  PositionedAppIcon(TabController tabController, int initialIndex)
      : this._tabController = tabController,
        this._initialIndex = initialIndex;

  @override
  _PositionedAppIconState createState() =>
      _PositionedAppIconState(_tabController, _initialIndex);
}

class _PositionedAppIconState extends State<PositionedAppIcon> {
  final double _iconSize = 50;
  TabController _tabController;
  final int _initialIndex;

  _PositionedAppIconState(this._tabController, this._initialIndex);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        /* be careful: -20 is because of the scaffold default padding */
        left: (MediaQuery.of(context).size.width / 2) - (_iconSize / 2) - 20,
        top: 70,
        child: FlatButton(
          onPressed: () => _tabController.animateTo(_initialIndex),
          child: Image.asset(
            'assets/tinder.png',
            height: _iconSize,
            width: _iconSize,
          ),
        ));
  }
}
