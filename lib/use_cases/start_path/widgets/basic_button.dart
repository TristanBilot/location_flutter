import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class BasicButton extends StatefulWidget {
  static const Weight = FontWeight.w700;
  static const FontSize = 21.0;

  final String text;
  final bool enabled;
  final Function onPressed;
  final double width;

  BasicButton(
    this.text, {
    this.enabled = true,
    this.onPressed,
    this.width,
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: widget.enabled
                ? Theme.of(context).primaryColor
                : Colors.black12),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: TextSF(
            widget.text,
            align: TextAlign.center,
            fontSize: BasicButton.FontSize,
            fontWeight: BasicButton.Weight,
            color: widget.enabled ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}
