import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountSubtitleText extends StatelessWidget {
  final String title;
  final double fontSize;

  const AccountSubtitleText(
    this.title, {
    this.fontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return TextSF(
      title,
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
    );
  }
}
