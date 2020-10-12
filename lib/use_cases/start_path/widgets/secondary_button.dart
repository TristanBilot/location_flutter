import 'package:flutter/material.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/textSF.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  SecondaryButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: TextSF(
        'LATER',
        color: Colors.black38,
        fontSize: BasicButton.FontSize * 0.8,
        fontWeight: BasicButton.Weight,
      ),
      onPressed: onPressed,
    );
  }
}
