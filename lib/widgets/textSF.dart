import 'package:flutter/material.dart';

class TextSF extends StatelessWidget {
  static const Weight = FontWeight.w600;
  static const FontSize = 14.0;
  // static const FontFamily = "SF Pro Display";
  static const LetterSpacing = 0.50;

  static const TitleWeight = FontWeight.w800;
  static const TitleSize = 30.0;

  static const TextSFStyle = TextStyle(
    fontWeight: Weight,
    fontSize: FontSize,
    // fontFamily: FontFamily,
    letterSpacing: LetterSpacing,
  );

  static const TextSFTitleStyle = TextStyle(
    fontWeight: TitleWeight,
    fontSize: TitleSize,
    // fontFamily: FontFamily,
    letterSpacing: LetterSpacing,
  );

  final String text;
  final TextAlign align;
  final TextStyle style;
  final double fontSize;
  final FontWeight fontWeight;
  final bool isTitle;
  final double letterSpacing;
  final TextOverflow overflow;
  final Color color;

  TextSF(
    this.text, {
    this.align,
    this.fontSize = FontSize,
    this.fontWeight = Weight,
    this.isTitle = false,
    this.letterSpacing,
    this.overflow,
    this.color,
    TextStyle style = const TextStyle(),
  }) : style = isTitle
            ? style.copyWith(
                fontWeight: TitleWeight,
                fontSize: TitleSize,
                letterSpacing: letterSpacing,
                color: color,
              )
            : style.copyWith(
                fontWeight: fontWeight,
                fontSize: fontSize,
                letterSpacing: letterSpacing,
                color: color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: style,
      overflow: overflow,
    );
  }
}
