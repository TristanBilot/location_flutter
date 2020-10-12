import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class BasicAlertButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  BasicAlertButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor,
        ),
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: TextSF(
          text,
          style: TextSF.TextSFTitleStyle.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
