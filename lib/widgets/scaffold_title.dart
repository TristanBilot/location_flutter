import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class ScaffoldTitle extends StatelessWidget {
  final String title;

  const ScaffoldTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return TextSF(
      title,
      fontSize: 18,
    );
  }
}
