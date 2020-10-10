import 'package:flutter/material.dart';

class TextSF extends StatelessWidget {
  final String data;
  final TextAlign align;
  final TextStyle style;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isTitle;
  final double letterSpacing;
  final String fontFamily;
  final Color color;

  TextSF(
    this.data, {
    this.align,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.isTitle = false,
    this.letterSpacing = 0.36,
    this.fontFamily = "SF Pro Display",
    this.color,
    TextStyle style = const TextStyle(),
  }) : style = isTitle
            ? style.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 30,
                fontFamily: fontFamily,
                letterSpacing: letterSpacing,
                color: color,
              )
            : style.copyWith(
                fontWeight: fontWeight,
                fontSize: fontSize,
                fontFamily: fontFamily,
                letterSpacing: letterSpacing,
                color: color);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: align,
      style: style,
    );
  }
}
