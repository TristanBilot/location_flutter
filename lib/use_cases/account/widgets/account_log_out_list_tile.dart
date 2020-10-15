import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountLogOutListTile extends StatelessWidget {
  static const Padding = 20.0;

  final String text;
  final Color color;
  final Function onPressed;

  const AccountLogOutListTile(this.text, {this.color, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AccountLogOutListTile.Padding,
        // bottom: AccountLogOutListTile.Padding,
      ),
      child: Card(
        elevation: 0,
        child: RawMaterialButton(
          onPressed: onPressed,
          child: Container(
            padding: EdgeInsets.only(
              top: 12,
              bottom: 12,
            ),
            child: TextSF(
              text,
              color: color,
              fontSize: TextSF.FontSize + 2,
              align: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
