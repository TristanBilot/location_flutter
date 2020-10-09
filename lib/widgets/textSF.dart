import 'package:flutter/material.dart';

class TextSF extends StatelessWidget {
  final String data;
  final TextAlign align;
  final TextStyle style;
  final double fontSize;
  final FontWeight fontWeight;

  TextSF(
    this.data, {
    this.align,
    this.fontSize,
    this.fontWeight,
    TextStyle style = const TextStyle(),
  }) : style = style.copyWith(
          fontWeight: fontWeight ?? FontWeight.w500,
          fontSize: fontSize ?? 14,
          fontFamily: "SF Pro Display",
          letterSpacing: 0.36,
          // color: Theme.of(context).textTheme.bodyText2
        );

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: align,
      style: style,
    );
  }
}
