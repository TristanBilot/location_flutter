import 'package:flutter/material.dart';
import 'package:location_project/widgets/gradient_icon.dart';

class LikeDislikeButton extends StatefulWidget {
  final IconData _icon;
  final MaterialColor _color1;
  final MaterialColor _color2;

  LikeDislikeButton(this._icon, this._color1, this._color2);

  @override
  _LikeDislikeButtonState createState() =>
      _LikeDislikeButtonState(_icon, _color1, _color2);
}

class _LikeDislikeButtonState extends State<LikeDislikeButton> {
  final IconData _icon;
  final MaterialColor _color1;
  final MaterialColor _color2;

  _LikeDislikeButtonState(this._icon, this._color1, this._color2);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      padding: EdgeInsets.all(12.0),
      shape: CircleBorder(),
      elevation: 3.0, // shade
      fillColor: Colors.white,
      onPressed: () => null,
      child: GradientIcon(
        _icon,
        50.0,
        LinearGradient(
          colors: <Color>[
            _color1,
            _color2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
