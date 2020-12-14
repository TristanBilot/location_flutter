import 'package:flutter/material.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/widgets/textSF.dart';

class BasicButton extends StatefulWidget {
  static const Weight = FontWeight.w700;
  static const FontSize = 21.0;
  static const CornerRadius = 10.0;

  final String text;
  final bool enabled;
  final Function onPressed;
  final double width;
  final double fontsSize;

  BasicButton(
    this.text, {
    this.enabled = true,
    this.onPressed,
    this.width,
    this.fontsSize = FontSize,
  });

  @override
  _BasicButtonState createState() => _BasicButtonState();
}

class _BasicButtonState extends State<BasicButton> {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      shape: CircleBorder(),
      onPressed: widget.onPressed,
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(BasicButton.CornerRadius)),
          // color: widget.enabled
          //     ? Theme.of(context).primaryColor
          //     : Colors.black12),
          gradient: widget.enabled
              ? AppGradient
              : LinearGradient(colors: [Colors.black12, Colors.black12]),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: TextSF(
            widget.text,
            align: TextAlign.center,
            fontSize: widget.fontsSize,
            fontWeight: BasicButton.Weight,
            color: widget.enabled ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}
