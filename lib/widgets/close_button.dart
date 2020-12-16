import 'package:flutter/material.dart';

class RoundedCloseButton extends StatefulWidget {
  final Color color;
  final Color iconColor;
  const RoundedCloseButton({
    this.color,
    this.iconColor,
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
            size: 22, color: widget.iconColor ?? Colors.white),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black45)],
            shape: BoxShape.circle,
            color: widget.color ?? _closeIconColor),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
