import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class BasicAlert extends StatelessWidget {
  final List<Widget> actions;
  final String title;
  final String content;
  final double titleFontSize;
  final double contentFontSize;
  final TextAlign titleAlignment;
  final EdgeInsets contentPadding;

  BasicAlert(
    this.title, {
    this.content,
    this.actions,
    this.titleFontSize = 26,
    this.contentFontSize = 17,
    this.titleAlignment,
    this.contentPadding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).backgroundColor,
      title: TextSF(
        title,
        fontSize: titleFontSize,
        fontWeight: FontWeight.w600,
        align: titleAlignment,
      ),
      content: content != null
          ? TextSF(
              content,
              fontSize: contentFontSize,
            )
          : SizedBox(),
      actions: actions,
      contentPadding: contentPadding,
    );
  }
}
