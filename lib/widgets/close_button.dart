import 'package:flutter/material.dart';

class RoundedCloseButton extends StatefulWidget {
  final Color color;
  final Color iconColor;
  final Function onPressed;
  final double iconSize;

  const RoundedCloseButton({
    this.color,
    this.iconColor,
    this.onPressed,
    this.iconSize = 22,
  });

  @override
  _RoundedCloseButtonState createState() => _RoundedCloseButtonState();
}

class _RoundedCloseButtonState extends State<RoundedCloseButton> {
  Color get _closeIconColor =>
      MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Theme.of(context).primaryColor
          : Color.fromRGBO(200, 200, 200, 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Icon(Icons.close,
            size: widget.iconSize, color: widget.iconColor ?? Colors.white),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black45)],
            shape: BoxShape.circle,
            color: widget.color ?? _closeIconColor),
      ),
      onTap: widget.onPressed ?? () => Navigator.pop(context),
    );
  }
}
