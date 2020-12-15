import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class TextSFGradient extends StatelessWidget {
  final TextAlign align;
  final double fontSize;
  final FontWeight fontWeight;

  TextSFGradient(
    this.text, {
    @required this.gradient,
    this.align,
    this.fontSize,
    this.fontWeight,
  });

  final String text;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: TextSF(
        text,
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: fontWeight,
        align: align,
      ),
    );
  }
}
