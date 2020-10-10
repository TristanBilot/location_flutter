import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class BasicButton extends StatefulWidget {
  final bool enabled;
  final Function onPressed;

  BasicButton(this.enabled, this.onPressed);

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
      elevation: 1.0,
      onPressed: widget.onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: widget.enabled
                ? Theme.of(context).primaryColor
                : Colors.black12),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: TextSF(
            "NEXT",
            align: TextAlign.center,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: widget.enabled ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}
